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
import Crashlytics
import AWSMobileClient
import Firebase

/** The visual styles in which the login controller can be displayed. */
@objc public enum LoginViewControllerStyle: Int {
    case lightTranslucent /* Light theme, with a translucent background showing the app content poking through. */
    case lightOpaque      /* Light theme, with a solid background color. */
    case darkTranslucent  /* Dark theme, with a translucent background showing the app content poking through. */
    case darkOpaque       /* Dark theme, with a solid background color. */
}

/** A protocol for third party objects to integrate with and manage the authentication 
    of user credentials. Used for integration with third party services like Amazon Cognito.
 */
//@objc(RLMAuthenticationProvider)
public protocol AuthenticationProvider: NSObjectProtocol {

    /** The credentials captured by the login controller (if set) */
    var username: String? { get set }
    var password: String? { get set }
    var isRegistering: Bool   { get set }
    var teamEmail: String? {get set}

    /**
     The provider will perform the necessary requests (asynchronously if desired) to obtain the
     required information from the third party service that can then be used to
     create an `RLMSynCredentials` object for input into the ROS Authentication server.
     */
    func authenticate(onCompletion: ((SignInResult?, Error?) -> Void)?)
    
    func signUp(onCompletion: ((SignUpResult?, Error?) -> Void)?)

    /**
     Not strictly required, but if the sign-in request is asynchronous and needs to be cancelled,
     this will be called to give the logic a chance to clean itself up.
     */
    func cancelAuthentication() -> Void
}

/** 
 A view controller showing an inpur form for logging into a Realm Object Server instance running
 on a remote server.
 */
@objc(RLMLoginViewController)
public class LoginViewController: UIViewController {
    
    //MARK: - Public Properties
    
    /** 
     The visual style of the login controller
    */
    public private(set) var style = LoginViewControllerStyle.lightTranslucent

    /**
     Sets whether the copyright label shown at the bottom of the
     view is visible or not.
     */
    public var isCopyrightLabelHidden: Bool {
        get { return self.loginView.isCopyrightLabelHidden }
        set { self.loginView.isCopyrightLabelHidden = newValue }
    }

    /**
     Sets the text shown in the copyright label.
     */
    public var copyrightLabelText: String {
        get { return self.loginView.copyrightLabelText }
        set { self.loginView.copyrightLabelText = newValue }
    }

    /**
     The username of the account that will either be logged in, or registered. While an email
     address is preferred, there are no specific formatting checks, so any string is valid.
     */
    public var username: String? {
        set { tableDataSource.username = newValue }
        get { return tableDataSource.username }
    }
    
    public var teamEmail: String? {
        set { tableDataSource.teamEmail = newValue }
        get { return tableDataSource.teamEmail }
    }
    
    public var confirmTeamEmail: String? {
        set {tableDataSource.confirmTeamEmail = newValue}
        get {return tableDataSource.confirmTeamEmail}
    }

    /**
     The pasword for this account that is being logged in, or registered. By default, there are
     no password security policies in place.
     */
    public var password: String? {
        set { tableDataSource.password = newValue }
        get { return tableDataSource.password }
    }

    /**
     When registering a new account, this field is used to confirm the password is as the user intended.
     The form validation check will fail if the form state is set to registering, and this string doesn't
     match `password` exactly.
     */
    public var confirmPassword: String? {
        set { tableDataSource.confirmPassword = newValue }
        get { return tableDataSource.confirmPassword }
    }

    /**
     Whether the view controller will allow new registrations, or
     simply only allow previously registered accounts to be entered.
    */
    public var allowsNewAccountRegistration: Bool {
        get { return self.loginView.canRegisterNewAccounts }
        set { self.loginView.canRegisterNewAccounts = newValue }
    }
    
    /**
     Manages whether the view controller is currently logging in an existing user,
     or registering a new user for the first time
    */
    public var isRegistering: Bool {
        set {
            setRegistering(newValue, animated: false)
        }
        get { return _isRegistering }
    }

    /**
     Transitions the view controller between the 'logging in' and 'signing up'
     states. Can be animated, or updated instantly.
     */
    public func setRegistering(_ isRegistering: Bool, animated: Bool) {
        guard _isRegistering != isRegistering else { return }
        _isRegistering = isRegistering
        tableDataSource.setRegistering(isRegistering, animated: animated)
        loginView.setRegistering(isRegistering, animated: animated)
        prepareForSubmission()
    }

    /**
     Upon successful login/registration, this callback block will be called,
     providing the user account object that was returned by the server.
    */
    public var loginSuccessfulHandler: ((SignInResult) -> Void)?

    /** 
     In cases where cancelling the login controller might be needed, show 
     a close button that can dismiss the view.
    */
    public var isCancelButtonHidden: Bool {
        // Proxy this property to the one managed directly by the view
        set { self.loginView.isCancelButtonHidden = newValue }
        get { return self.loginView.isCancelButtonHidden }
    }

    /**
     When integrating with third party services that require another web service to
     verify the credentials before they are submitted to the Realm authentication server,
     this property can be set to an object capable of performing this request and generation
     the subsequent `RLMSyncCredentials` objects.
    */
    public var authenticationProvider: AuthenticationProvider?

    /**
     A model object that exposes the input validation logic of the form
     */
    public lazy var formValidationManager: LoginCredentialsValidationProtocol = LoginCredentialsValidation()

    //MARK: - Private Properties

    /* State tracking */
    private var _isRegistering = false
    private var _isSecureConnection = false

    /* The `UIView` subclass that manages all view content in this view controller */
    private var loginView: LoginView {
        return (self.view as! LoginView)
    }

    /* A view model object to manage the table view */
    private let tableDataSource = LoginTableViewDataSource()

    /* A model object to manage receiving keyboard resize events from the system. */
    private let keyboardManager = LoginKeyboardManager()

    /* State Convienience Methods */
    private var isTranslucent: Bool  {
        return style == .lightTranslucent || style == .darkTranslucent
    }
    
    private var isDarkStyle: Bool {
        return style == .darkTranslucent || style == .darkOpaque
    }
    
    //MARK: - Status Bar Appearance
    override public var prefersStatusBarHidden: Bool { return false }
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return isDarkStyle ? .lightContent : .default
    }
    
    //MARK: - Class Creation
    
    public init(style: LoginViewControllerStyle) {
        super.init(nibName: nil, bundle: nil)
        self.style = style
        modalPresentationStyle = isTranslucent ? .overFullScreen : .fullScreen
        modalTransitionStyle = .crossDissolve
        modalPresentationCapturesStatusBarAppearance = true
    }

    convenience init() {
        self.init(style: .lightTranslucent)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        authenticationProvider?.cancelAuthentication()
    }

    //MARK: - View Management

    override public func loadView() {
        super.loadView()
        self.view = LoginView(darkStyle: isDarkStyle, translucentStyle: isTranslucent)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        transitioningDelegate = loginView

        // Set up the data source for the table view
        tableDataSource.isDarkStyle = isDarkStyle
        tableDataSource.tableView = loginView.tableView
        tableDataSource.formInputChangedHandler = { self.prepareForSubmission() }

        // Set callbacks for the accessory view buttons
        loginView.didTapCloseHandler = {[weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        loginView.didTapLogInHandler = { self.submitLoginRequest() }
        loginView.didTapRegisterHandler = { self.setRegistering(!self.isRegistering, animated: true) }
        
        loginView.didTapForgotPasswordHandler = {
            //Show the forgot password vc
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let forgotPassVC = mainStoryboard.instantiateViewController(withIdentifier: "forgotPassword")
            
            self.present(forgotPassVC, animated: true, completion: nil)
        }

        // Configure the keyboard manager for the login view
        keyboardManager.keyboardHeightDidChangeHandler = { newHeight in
            self.loginView.keyboardHeight = newHeight
            self.loginView.animateContentInsetTransition()
        }

        prepareForSubmission()
        loginView.updateCloseButtonVisibility()
    }

    //MARK: - Form Submission -

    private func prepareForSubmission() {
        // Validate the supplied credentials
        var isFormValid = true

        // Check each credential against our external validator
        isFormValid = formValidationManager.isValidUsername(username) && isFormValid
        isFormValid = formValidationManager.isValidPassword(password) && isFormValid

        // If registering, confirm password matches the confirm password field too
        if isRegistering {
            isFormValid = isFormValid && formValidationManager.isPassword(password, matching: confirmPassword)
            isFormValid = formValidationManager.isValidEmail(teamEmail) && isFormValid
            isFormValid = formValidationManager.isEmail(teamEmail, matching: confirmTeamEmail) && isFormValid
        }

        // Enable the 'submit' button if all is valid
        loginView.footerView.isSubmitButtonEnabled = isFormValid
    }

    private func submitLoginRequest() {
        // Show the spinner view on the login button
        loginView.footerView.isSubmitting = true

        if let authenticationProvider = self.authenticationProvider {
            // Copy over the current credentials
            authenticationProvider.username = self.username!
            authenticationProvider.password = self.password!
            authenticationProvider.isRegistering = self.isRegistering
            
            authenticationProvider.teamEmail = self.teamEmail

            // Perform the request
            if self.isRegistering {
                authenticationProvider.signUp { (result, error) in
                    DispatchQueue.main.async {
                        if let result = result {
                            var state = ""
                            switch result.signUpConfirmationState {
                            case .confirmed:
                                //Cool?
                                self.showError(title: "Good to Go", message: "Seems like you are already good to go, try signing in now.")
                                self.setRegistering(false, animated: true)
                                state = "confirmed"
                            case .unconfirmed:
                                //Needs to confirm via email
                                self.showError(title: "Verification Required", message: "Verification is required via \(result.codeDeliveryDetails!.deliveryMedium) sent to \(result.codeDeliveryDetails!.destination ?? "unkown"). Please do this, then try signing in.")
                                self.setRegistering(false, animated: true)
                                state = "unconfirmed"
                            case .unknown:
                                assertionFailure()
                                state = "unknown"
                            }
                            
                            Globals.recordAnalyticsEvent(eventType: AnalyticsEventSignUp, attributes: [AnalyticsParameterSignUpMethod:"team_userpass", "state":state])
                        } else if let error = error {
                            CLSNSLogv("Error Signing Up: \(error)", getVaList([]))
                            Crashlytics.sharedInstance().recordError(error)
                            self.showError(title: "Error Signing Up", message: (error as? AWSMobileClientError)?.message ?? error.localizedDescription)
                        }
                        self.loginView.footerView.isSubmitting = false
                    }
                }
            } else {
                authenticationProvider.authenticate { (result, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            CLSNSLogv("Error signing in: \(error)", getVaList([]))
                            Crashlytics.sharedInstance().recordError(error)
                            self.showError(title: "Error Signing In", message: (error as? AWSMobileClientError)?.message ?? error.localizedDescription)
                        } else if let result = result {
                            self.loginSuccessfulHandler?(result)
                            Globals.recordAnalyticsEvent(eventType: AnalyticsEventLogin, attributes: [AnalyticsParameterMethod:"team_userpass"])
                        }
                        self.loginView.footerView.isSubmitting = false
                    }
                }
            }
        } else {
            assertionFailure()
        }
    }

    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
