//
//  RootViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/5/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    let realmController = RealmController.realmController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Check if the user is logged in and switch before even presenting this view
        if realmController.isLoggedIn {
            //We are logged in, switch to the team list view
            switchToTeamList()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Present log in screen
        let loginVC = LoginViewController(style: .darkOpaque)
        loginVC.isCancelButtonHidden = true
        loginVC.serverURL = realmController.syncAuthURL.absoluteString
        loginVC.isServerURLFieldHidden = true
        
        loginVC.authenticationProvider = AWSCognitoAuthenticationProvider(serviceRegion: .USEast1, userPoolID: "us-east-1_FuyxJ3oI6", clientID: "50a007212mgh063emptr07n5tu", clientSecret: "i2ujhnqfmnfi0ishlme00qi0pms5s4auhi5p7hv8fc223afcchp")
        
        loginVC.loginSuccessfulHandler = {user,teamNumber in
            self.realmController.currentSyncUser = user
            self.realmController.openSyncedRealm(withSyncUser: user, forTeam: teamNumber)
            self.switchToTeamList()
        }
        
        self.present(loginVC, animated: false, completion: nil)
    }
    
    func switchToTeamList() {
        let teamListSplitVC = storyboard?.instantiateViewController(withIdentifier: "teamListMasterVC")
        self.view.window?.rootViewController = teamListSplitVC!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
