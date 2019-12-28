//
//  ForgotPasswordViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/24/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import AWSMobileClient

class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var teamNumberField: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barStyle = .black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func continuePressed(_ sender: UIBarButtonItem) {
        let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicator.frame = CGRect(x: self.view.frame.width / 2 - 20, y: self.view.frame.height / 2 - 20, width: 20, height: 20)
        self.view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
        AWSMobileClient.default().forgotPassword(username: teamNumberField.text ?? "?") { (result, error) in
            DispatchQueue.main.async {
                loadingIndicator.stopAnimating()
                loadingIndicator.removeFromSuperview()
                
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    Globals.recordAnalyticsEvent(eventType: "forgot_password_reset_requested", attributes: ["successful":"false"])
                } else if let result = result {
                    switch result.forgotPasswordState {
                    case .confirmationCodeSent:
                        //It was successful, show the confirmation screen
                        self.performSegue(withIdentifier: "confirm", sender: self)
                        Globals.recordAnalyticsEvent(eventType: "forgot_password_reset_requested", attributes: ["successful":"true"])
                    case .done:
                        assertionFailure()
                    }
                }
            }
        }
    }

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: self)

        if segue.identifier == "confirm" {
            let confirmVC = segue.destination as! ConfirmForgotPasswordViewController
            confirmVC.teamNumber = teamNumberField.text
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
