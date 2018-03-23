//
//  OnboardingPathChooserViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/23/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit
import SSBouncyButton
import Crashlytics

let isSpectatorModeKey = "FAST-IsInSpectatorMode"

class OnboardingPathChooserViewController: UIViewController {
    @IBOutlet weak var spectatorView: UIView!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var logInView: UIView!
    
    var spectatorBouncyButton: UIButton!
    var logInBouncyButton: UIButton!
    var signUpBouncyButton: UIButton!
    
    let buttonCornerRadius: CGFloat = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
    
    func setOnboardingCompletion() {
        UserDefaults.standard.set(true, forKey: onboardingCompletedStatusKey)
    }
    
    @objc func spectatorPressed() {
        setOnboardingCompletion()
        
        //Switch to the team list
        let teamListVC = storyboard?.instantiateViewController(withIdentifier: "teamListMasterVC")
        
        RealmController.realmController.openLocalRealm()
        UserDefaults.standard.setValue(true, forKey: isSpectatorModeKey)
        
        self.view.window?.rootViewController = teamListVC
        
        Answers.logCustomEvent(withName: "Onboarding Completed", customAttributes: ["Onboarded Route":"Spectator"])
    }
    
    @objc func logInPressed() {
        setOnboardingCompletion()
        
        (UIApplication.shared.delegate as! AppDelegate).displayLogin()
        
        Answers.logCustomEvent(withName: "Onboarding Completed", customAttributes: ["Onboarded Route":"Log In"])
    }
    
    @objc func signUpPressed() {
        setOnboardingCompletion()
        
        (UIApplication.shared.delegate as! AppDelegate).displayLogin(isRegistering: true)
        
        Answers.logCustomEvent(withName: "Onboarding Completed", customAttributes: ["Onboarded Route":"Sign Up"])
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
