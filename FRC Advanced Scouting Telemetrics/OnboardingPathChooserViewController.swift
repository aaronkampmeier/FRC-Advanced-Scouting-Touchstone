//
//  OnboardingPathChooserViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/23/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit
import AWSMobileClient
import Crashlytics
import AuthenticationServices

class OnboardingPathChooserViewController: UIViewController {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    var emailLoginButton: UIButton!
    
    let buttonCornerRadius: CGFloat = 5
    
//    let pinpoint = Globals.appDelegate.pinpoint
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        descriptionLabel.text = /*"If you're a spectator (anyone who isn't scouting data), just use FAST without logging in.*/ "To use FAST to scout teams, track performance statistics, and sync data across all of your team, log in or sign up for a team account."
        descriptionLabel.text = "Welcome! To use FAST to scout teams, track performance statistics, and sync data between all of your team members, log in or sign up for a personal account.\nIf you were using FAST prior to the 2020 season, please note that team accounts have been phased out in favor of personal accounts. Every member on your team should have their own account from now on."
        
        //Set up the provider buttons
        if #available(iOS 13.0, *) {
            let appleButton = ASAuthorizationAppleIDButton(type: .continue, style: .whiteOutline)
            appleButton.addTarget(self, action: #selector(loginWithApplePressed), for: .touchUpInside)
            loginProviderStackView.addArrangedSubview(appleButton)
        } else {
            // Fallback on earlier versions
        }
        
        emailLoginButton = UIButton()
        emailLoginButton?.backgroundColor = .systemBlue
        emailLoginButton?.layer.cornerRadius = buttonCornerRadius
        emailLoginButton?.setTitle("Continue with Personal Account", for: .normal)
        emailLoginButton?.addTarget(self, action: #selector(logInPressed), for: .touchUpInside)
        
        loginProviderStackView.addArrangedSubview(emailLoginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loginWithGoogle() {
        self.showLogin(identityProvider: "Google")
    }
    
    @objc func loginWithApplePressed() {
        self.showLogin(identityProvider: "SignInWithApple")
    }
    
    @objc func logInPressed() {
        
        self.showLogin(identityProvider: nil)
    }
    
    func showLogin(identityProvider: String? = nil) {
        //Create a navigation controller to present it in
        let authNavController = UINavigationController(rootViewController: UIViewController())
        let hostedUIOptions = HostedUIOptions(scopes: ["openid", "email", "profile"], identityProvider: identityProvider)
        
        AWSMobileClient.default().showSignIn(navigationController: authNavController, hostedUIOptions: hostedUIOptions) { (userState, error) in
//            authNavController.dismiss(animated: true, completion: nil)
            if let error = error {
                CLSNSLogv("Error authenticating user: \(error)", getVaList([]))
            }
            
            CLSNSLogv("New User State after auth finsihed: \(String(describing: userState))", getVaList([]))
            
        }
        
        Globals.recordAnalyticsEvent(eventType: "onboarding_completed", attributes: ["path":"login", "identityProvider":identityProvider ?? "n/a"])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
