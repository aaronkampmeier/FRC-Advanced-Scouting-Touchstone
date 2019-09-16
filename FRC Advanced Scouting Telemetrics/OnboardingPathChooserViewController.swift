//
//  OnboardingPathChooserViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/23/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit
//import SSBouncyButton

class OnboardingPathChooserViewController: UIViewController {
    @IBOutlet weak var spectatorView: UIView!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var logInView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var spectatorBouncyButton: UIButton!
    var logInBouncyButton: UIButton!
    var signUpBouncyButton: UIButton!
    
    let buttonCornerRadius: CGFloat = 5
    
//    let pinpoint = Globals.appDelegate.pinpoint
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        descriptionLabel.text = /*"If you're a spectator (anyone who isn't scouting data), just use FAST without logging in.*/ "To use FAST to scout teams, track performance statistics, and sync data across all of your team, log in or sign up for a team account."
        
        spectatorView.backgroundColor = nil
        logInView.backgroundColor = nil
        signUpView.backgroundColor = nil
        
        spectatorBouncyButton = UIButton() //SSBouncyButton()
        logInBouncyButton = UIButton() // SSBouncyButton()
        signUpBouncyButton = UIButton() // SSBouncyButton()
        
//        spectatorBouncyButton.tintColor = UIColor.blue
        spectatorBouncyButton.backgroundColor = UIColor.systemBlue
        spectatorBouncyButton.layer.cornerRadius = buttonCornerRadius
        spectatorBouncyButton.setTitle("I'm a Spectator", for: .normal)
        spectatorBouncyButton.addTarget(self, action: #selector(spectatorPressed), for: .touchUpInside)
        
//        logInBouncyButton.tintColor = UIColor.darkGray
        if #available(iOS 13.0, *) {
            logInBouncyButton.backgroundColor = UIColor.systemGray2
        } else {
            // Fallback on earlier versions
            logInBouncyButton.backgroundColor = UIColor.lightGray
        }
        logInBouncyButton.layer.cornerRadius = buttonCornerRadius
        logInBouncyButton.setTitle("Log into Existing Account", for: .normal)
        logInBouncyButton.addTarget(self, action: #selector(logInPressed), for: .touchUpInside)
        
//        signUpBouncyButton.tintColor = UIColor.purple
        signUpBouncyButton.backgroundColor = UIColor.systemBlue
        signUpBouncyButton.layer.cornerRadius = buttonCornerRadius
        signUpBouncyButton.setTitle("Create a Team Account", for: .normal)
        signUpBouncyButton.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        
        self.view.addSubview(spectatorBouncyButton)
        self.view.addSubview(logInBouncyButton)
        self.view.addSubview(signUpBouncyButton)
        
        updateButtonFrames()
        
        //TODO: Fix Spectator Implementation
        spectatorBouncyButton.isHidden = true
    }
    
    func updateButtonFrames() {
        spectatorBouncyButton.frame = spectatorView.frame
        signUpBouncyButton.frame = signUpView.frame
        logInBouncyButton.frame = logInView.frame
    }
    
    override func viewDidLayoutSubviews() {
        updateButtonFrames()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func spectatorPressed() {
        
        //Switch to the team list
        let teamListVC = storyboard?.instantiateViewController(withIdentifier: "teamListMasterVC")
        
        UserDefaults.standard.setValue(true, forKey: Globals.isSpectatorModeKey)
        
        self.view.window?.rootViewController = teamListVC
        
        Globals.recordAnalyticsEvent(eventType: "onboarding_completed", attributes: ["path":"spectator"])
    }
    
    @objc func logInPressed() {
        
        self.showLogin(isRegistering: false)
        
        Globals.recordAnalyticsEvent(eventType: "onboarding_completed", attributes: ["path":"login"])
    }
    
    @objc func signUpPressed() {
        
        self.showLogin(isRegistering: true)
        
        Globals.recordAnalyticsEvent(eventType: "onboarding_completed", attributes: ["path":"sign_up"])
    }
    
    func showLogin(isRegistering: Bool) {
        //Present log in screen
        let loginVC = LoginViewController(style: .darkOpaque)
        loginVC.isCancelButtonHidden = false
        loginVC.isCopyrightLabelHidden = true
        loginVC.authenticationProvider = AWSCognitoAuthenticationProvider()
        
        loginVC.loginSuccessfulHandler = {result in
            UserDefaults.standard.set(false, forKey: Globals.isSpectatorModeKey)
            
            if #available(iOS 13.0, *) {
                // iOS 13 and up uses scenes and those will switch views depending on login state automatically.
            } else {
                loginVC.dismiss(animated: false, completion: nil)
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                self.view.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC")
            }
        }
        
        loginVC.setRegistering(isRegistering, animated: false)
        present(loginVC, animated: true, completion: nil)
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
