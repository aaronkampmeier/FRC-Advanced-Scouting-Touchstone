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
        spectatorBouncyButton.backgroundColor = UIColor.blue
        spectatorBouncyButton.layer.cornerRadius = buttonCornerRadius
        spectatorBouncyButton.setTitle("I'm a Spectator", for: .normal)
        spectatorBouncyButton.addTarget(self, action: #selector(spectatorPressed), for: .touchUpInside)
        
//        logInBouncyButton.tintColor = UIColor.darkGray
        logInBouncyButton.backgroundColor = UIColor.darkGray
        logInBouncyButton.layer.cornerRadius = buttonCornerRadius
        logInBouncyButton.setTitle("Log into Existing Account", for: .normal)
        logInBouncyButton.addTarget(self, action: #selector(logInPressed), for: .touchUpInside)
        
//        signUpBouncyButton.tintColor = UIColor.purple
        signUpBouncyButton.backgroundColor = UIColor.blue
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
        
//        let loginVC = (UIApplication.shared.delegate as! AppDelegate).logInViewController()
//        self.present(loginVC, animated: true, completion: nil)
        Globals.appDelegate.displayLogin(isRegistering: false, onVC: self)
        
        Globals.recordAnalyticsEvent(eventType: "onboarding_completed", attributes: ["path":"login"])
    }
    
    @objc func signUpPressed() {
        
//        let loginVC = (UIApplication.shared.delegate as! AppDelegate).logInViewController()
//        self.present(loginVC, animated: true, completion: nil)
//        loginVC.setRegistering(true, animated: false)
        
        Globals.appDelegate.displayLogin(isRegistering: true, onVC: self)
        
        Globals.recordAnalyticsEvent(eventType: "onboarding_completed", attributes: ["path":"sign_up"])
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
