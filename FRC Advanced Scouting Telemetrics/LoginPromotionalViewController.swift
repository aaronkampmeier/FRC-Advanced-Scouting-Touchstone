//
//  LoginPromotionalViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 4/7/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

class LoginPromotionalViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textView.text = ""
        if let rtf = Bundle.main.url(forResource: "LoginPromotionalText", withExtension: "rtf") {
            do {
                let attributedString = try NSAttributedString(url: rtf, options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                textView.isScrollEnabled = false
                textView.attributedText = attributedString
                textView.font = UIFont.systemFont(ofSize: 18)
            } catch {
                CLSNSLogv("Unable to read About.rtf file", getVaList([]))
            }
        }
        
        loginButton.backgroundColor = UIColor.blue
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.isScrollEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        Globals.recordAnalyticsEvent(eventType: AnalyticsEventSelectContent, attributes: ["content_type":"screen","item_id": "login","from":"login_promotional"])
        
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
        
        loginVC.setRegistering(true, animated: false)
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
