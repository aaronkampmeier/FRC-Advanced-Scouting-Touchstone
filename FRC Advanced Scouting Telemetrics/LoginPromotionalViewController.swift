//
//  LoginPromotionalViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 4/7/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit
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
        
//        Answers.logContentView(withName: "Login Promotional", contentType: "Promotional Page", contentId: nil, customAttributes: nil)
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
        Answers.logCustomEvent(withName: "Promotional -> Login", customAttributes: nil)
        
//        let loginVC = (UIApplication.shared.delegate as! AppDelegate).logInViewController()
//        self.present(loginVC, animated: true, completion: nil)
        
        Globals.appDelegate.displayLogin()
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
