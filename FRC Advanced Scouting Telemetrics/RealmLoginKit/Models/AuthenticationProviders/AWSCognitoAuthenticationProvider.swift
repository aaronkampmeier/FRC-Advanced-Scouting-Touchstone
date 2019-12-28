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
import AWSCognitoIdentityProvider
import AWSMobileClient
import Crashlytics

public class AWSCognitoAuthenticationProvider: NSObject, AuthenticationProvider, AWSCognitoIdentityInteractiveAuthenticationDelegate {

    // Authentican Provider Input Credentials
    public var username: String? = nil
    public var password: String? = nil
    public var isRegistering: Bool = false
    public var teamEmail: String? = nil

    // Task token to let us cancel requests as needed
    private var cancellationTokenSource: AWSCancellationTokenSource?

    public override init() {

        super.init()
    }

    public func cancelAuthentication() {
        cancellationTokenSource?.cancel()
    }

    public func authenticate(onCompletion: ((SignInResult?, Error?) -> Void)?) {
        AWSMobileClient.default().signIn(username: username!, password: password!) { (result, error) in
            onCompletion?(result, error)
        }
    }
    
    public func signUp(onCompletion: ((SignUpResult?, Error?) -> Void)?) {
        AWSMobileClient.default().signUp(username: username!, password: password!, userAttributes: ["email":teamEmail!]) { (result, error) in
            onCompletion?(result, error)
        }
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

    // Cognito returns the error message in a "message" property in
    // 'userInfo'. This method copies that string to 'localizedDescription' 
    // for easier access
//    private func formattedError(_ error: Error?) -> Error? {
//        if let e = error as NSError? {
//            var userInfo = e.userInfo
//            let message = userInfo["message"] as? String
//            var newError = e as Error
////            newError.localizedDescription = message
//            return NSError(domain: e.domain, code: e.code, userInfo: userInfo)
//        } else {
//            return nil
//        }
//    }
    
}
