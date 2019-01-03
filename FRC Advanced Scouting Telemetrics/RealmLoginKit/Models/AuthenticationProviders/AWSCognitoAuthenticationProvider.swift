////////////////////////////////////////////////////////////////////////////
//
// Copyright 2017 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import UIKit
import Realm
import AWSCognitoIdentityProvider
import AWSMobileClient
import Crashlytics

public class AWSCognitoAuthenticationProvider: NSObject, AuthenticationProvider, AWSCognitoIdentityInteractiveAuthenticationDelegate {

    // Authentican Provider Input Credentials
    public var username: String? = nil
    public var password: String? = nil
    public var isRegistering: Bool = false
    public var teamEmail: String? = nil

    // AWS Account Credentials
    private let serviceRegion: AWSRegionType
    private let userPoolID: String
    private let clientID: String
    private let clientSecret: String
    private let userPool: AWSCognitoIdentityUserPool

    // Task token to let us cancel requests as needed
    private var cancellationTokenSource: AWSCancellationTokenSource?

    public override init() {
        // Capture the Cognito account tokens + settings
        self.serviceRegion = .USEast1
        self.userPoolID = Keys.userPoolID
        self.clientID = Keys.appClientID
        self.clientSecret = Keys.appClientSecret

        // Access the User Pool object containing our users
        let serviceConfiguration = AWSServiceConfiguration(region: self.serviceRegion, credentialsProvider: nil)
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: self.clientID, clientSecret: self.clientSecret, poolId: self.userPoolID)
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey:"RealmLoginKit")
        self.userPool = AWSCognitoIdentityUserPool(forKey: "RealmLoginKit")

        super.init()
        
        self.userPool.delegate = self
    }

    public func cancelAuthentication() {
        cancellationTokenSource?.cancel()
    }

    public func authenticate(onCompletion: ((RLMSyncCredentials?, Error?) -> Void)?) {
        // Cancel any previous operations if they are still pending
        cancellationTokenSource?.cancel()
        cancellationTokenSource = nil

        // Create a new cancellation token source
        cancellationTokenSource = AWSCancellationTokenSource()

        // Trigger either a new reigstration or an existing login
        if self.isRegistering {
            registerNewAccount(onCompletion: onCompletion)
        }
        else {
            logIntoExistingAccount(onCompletion: onCompletion)
        }
    }

    private func registerNewAccount(onCompletion: ((RLMSyncCredentials?, Error?) -> Void)?) {
        // Any additional, potentially required attributes submitted along with the username and password credentials
        let attributes = [AWSCognitoIdentityUserAttributeType(name: "email", value: teamEmail!)]

        // The block called when the response from a signup request is received
        let signUpBlock: ((AWSTask<AWSCognitoIdentityUserPoolSignUpResponse>) -> Void) = { task in
            if (task.error != nil) {
                let error = task.error! as NSError
                Answers.logSignUp(withMethod: "AWS Cognito", success: NSNumber(booleanLiteral: false), customAttributes: ["Code":error.code.description])
                onCompletion?(nil, self.formattedError(task.error! as NSError))
                return
            }

            let _ = task.result!
            
            //Log this event
            Answers.logSignUp(withMethod: "AWS Cognito", success: NSNumber(booleanLiteral: true), customAttributes: ["Team":self.username ?? "Unk"])
            
            //The user signed up but now needs to confirm their account
            
            onCompletion?(nil, AWSCognitoError.NeedUserVerification)
        }

        // Make the initial signup request to the Cognito User Pool
        self.userPool.signUp(username!, password: password!, userAttributes: attributes, validationData: nil).continueWith(block: { task -> Any? in
            DispatchQueue.main.async { signUpBlock(task) }
            return nil
        }, cancellationToken: cancellationTokenSource!.token)
    }
    
    enum AWSCognitoError: Error {
        case NeedUserVerification
        
        var localizedDescription: String {
            get {
                switch self {
                case .NeedUserVerification:
                    return "Signup successful, now verify your email using the message sent to you before singing in."
                }
            }
        }
    }

    private func logIntoExistingAccount(onCompletion: ((RLMSyncCredentials?, Error?) -> Void)?) {
        // Set up the block that will be called when we get a response from the server
        let getUserSessionBlock: ((AWSTask<AWSCognitoIdentityUserSession>) -> Void) = { task in
            if (task.error != nil) {
                let error = task.error! as NSError
                Answers.logLogin(withMethod: "AWS Cognito", success: NSNumber.init(booleanLiteral: false), customAttributes: ["Code": error.code.description])
                onCompletion?(nil, self.formattedError(task.error! as NSError))
                return
            }

            let userSession = task.result!
            
            //Save the team that we are logging into
            UserDefaults.standard.set(self.username, forKey: "LoggedInTeam")
            
            //Log some metrics
            Crashlytics.sharedInstance().setUserName(self.username)
            Answers.logLogin(withMethod: "AWS Cognito", success: NSNumber(booleanLiteral: true), customAttributes: ["Team":self.username ?? "Unk"])

            // Extract the token from the user session and set up the resulting SyncCredentials objects
            let credentials = RLMSyncCredentials(customToken: userSession.accessToken!.tokenString, provider: RLMIdentityProvider(rawValue: "cognito"), userInfo: nil)
            onCompletion?(credentials, nil)
        }

        // Perform the login request
        let user = self.userPool.getUser(username!)
        user.getSession(username!, password: password!, validationData: nil).continueWith(block: { task -> Any? in
            DispatchQueue.main.async { getUserSessionBlock(task) }
            return nil
        }, cancellationToken: cancellationTokenSource!.token)
        
        //Added for new stuff
        AWSMobileClient.sharedInstance().signIn(username: username!, password: password!) {signInResult, error in
            if let error = error {
                CLSNSLogv("Error Signing In: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
            } else if let signInResult = signInResult {
                switch signInResult.signInState {
                case .signedIn:
                    CLSNSLogv("Now Signed In", getVaList([]))
                default:
                    CLSNSLogv("New User State: \(signInResult)", getVaList([]))
                }
            }
        }
    }
    
    
    //Forgot Password
    public func forgotPassword(username: String, onCompletion: @escaping (Error?) -> Void) {
        let user = self.userPool.getUser(username)
        user.forgotPassword().continueWith {task in
            onCompletion(self.formattedError(task.error as NSError?))
            
            return nil
        }
        
    }
    
    public func confirmForgotPassword(username: String, confirmationKey: String, withNewPassword newPassword: String, onCompletion: @escaping (Error?) -> Void) {
        let user = self.userPool.getUser(username)
        user.confirmForgotPassword(confirmationKey, password: newPassword).continueWith {task in
            onCompletion(self.formattedError(task.error as NSError?))
            
            return nil
        }
    }

    // Cognito returns the error message in a "message" property in
    // 'userInfo'. This method copies that string to 'localizedDescription' 
    // for easier access
    private func formattedError(_ error: NSError?) -> NSError? {
        if let error = error {
            var userInfo = error.userInfo
            userInfo[NSLocalizedDescriptionKey] = userInfo["message"]
            return NSError(domain: error.domain, code: error.code, userInfo: userInfo)
        } else {
            return nil
        }
    }
    
    
    //<--- AWSCognitoIdentityInteractiveAuthenticationDelegate --->
//    public func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
//
//    }
}
