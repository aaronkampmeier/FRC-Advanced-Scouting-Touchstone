//
//  SignInViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/3/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    @IBOutlet weak var teamPasswordField: UITextField!
    @IBOutlet weak var teamNumberField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        logInButton.backgroundColor = UIColor.blue
        logInButton.setTitleColor(UIColor.white, for: .normal)
        logInButton.layer.cornerRadius = 5
        
        loadingView.alpha = 0.6
        loadingView.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logInPressed(_ sender: UIButton) {
        loadingView.isHidden = false
        //Call the log in function
        //TODO: Sanitize Data
        RealmController.realmController.logIn(toTeam: teamNumberField.text ?? "", withUsername: teamNumberField.text ?? "", andPassword: teamPasswordField.text ?? "") {error in
            self.loadingView.isHidden = true
            if let error = error {
                let alertController = UIAlertController(title: "Error Signing In", message: "There was an error logging in. Make sure your team password is correct and you have internet connection. (\(error.localizedDescription))", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
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
