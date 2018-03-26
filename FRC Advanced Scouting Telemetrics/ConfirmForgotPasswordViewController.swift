//
//  ConfirmForgotPasswordViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/24/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics

class ConfirmForgotPasswordViewController: UIViewController {
    @IBOutlet weak var confirmationCodeField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    var teamNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barStyle = .black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        let formValidation = LoginCredentialsValidation()
        
        guard formValidation.isValidPassword(newPasswordField.text) && formValidation.isPassword(newPasswordField.text, matching: confirmPasswordField.text) else {
            //Show an error that the password does not line up
            let alert = UIAlertController(title: "Invalid Password", message: "Your password is invalid or the two passwords you entered do not line up. Try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //Passwords are valid, now try to confirm
        let cognitoManager = AWSCognitoAuthenticationProvider()
        cognitoManager.confirmForgotPassword(username: self.teamNumber!, confirmationKey: confirmationCodeField.text ?? "", withNewPassword: newPasswordField.text!) {error in
            DispatchQueue.main.async {
                if let error = error {
                    //Throw an error
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    Answers.logCustomEvent(withName: "Forgot Password Reset Completed", customAttributes: ["Successful":false])
                } else {
                    //No error
                    let alert = UIAlertController(title: "Success", message: "The password change was successful. Try logging in.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                        //Disimiss all parts of forgot password flow
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    Answers.logCustomEvent(withName: "Forgot Password Reset Completed", customAttributes: ["Successful":true])
                }
            }
        }
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
