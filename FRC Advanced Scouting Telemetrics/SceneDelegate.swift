//
//  SceneDelegate.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 7/16/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import UIKit
import AWSMobileClient
import Crashlytics

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        CLSNSLogv("Will Connect Scene To Session", getVaList([]))
        
        //Restore activity for the session
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        switch AWSMobileClient.sharedInstance().currentUserState {
        case .signedOut:
            //Show the sign in flow
            window?.rootViewController = mainStoryboard.instantiateViewController(identifier: "onboarding")
        case .signedIn:
            //Add user activity restoration logic
            
            self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC")
        case .guest:
            if Globals.isInSpectatorMode {
                self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC")
            } else {
                //Show sign in
                window?.rootViewController = mainStoryboard.instantiateViewController(identifier: "onboarding")
            }
        default:
            break
        }
        
        AWSMobileClient.sharedInstance().addUserStateListener(self) {[weak self] (userState, attributes) in
            //Update the view to reflect
            DispatchQueue.main.async {
                switch userState {
                case .signedOut:
                    //Show the sign in flow
                    self?.window?.rootViewController = mainStoryboard.instantiateViewController(identifier: "onboarding")
                case .signedIn:
                    //User activity restoration logic
                    
                    self?.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC")
                case .guest:
                    if Globals.isInSpectatorMode {
                        self?.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC")
                    } else {
                        //Show sign in
                        self?.window?.rootViewController = mainStoryboard.instantiateViewController(identifier: "onboarding")
                    }
                default:
                    break
                }
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        NSLog("Scene Will Enter Foreground")
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        NSLog("Scene Did Become Active")
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
    }
}
