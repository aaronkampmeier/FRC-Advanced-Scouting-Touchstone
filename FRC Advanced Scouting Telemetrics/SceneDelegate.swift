//
//  SceneDelegate.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 7/16/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSAppSync
import Crashlytics

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        CLSNSLogv("Will Connect Scene To Session", getVaList([]))
        
        ///MAKE SURE TO UPDATE ANY NEW LOGIC HERE INTO THE AppDelegate AS WELL FOR iOS 12 AND BELOW
        
        //Restore activity for the session
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        switch AWSMobileClient.default().currentUserState {
        case .signedOut:
            //Show the sign in flow
            window?.rootViewController = mainStoryboard.instantiateViewController(identifier: "onboarding")
        case .signedIn:
            self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC")
            
            //User activity restoration logic
            if let activity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
                self.scene(scene, continue: activity)
            }
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
        
        AWSMobileClient.default().addUserStateListener(self) {[weak self] (userState, attributes) in
            //Update the view to reflect
            DispatchQueue.main.async {
                switch userState {
                case .signedOut:
                    //Show the sign in flow
                    self?.window?.rootViewController = mainStoryboard.instantiateViewController(identifier: "onboarding")
                case .signedIn:
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
    
    func presentViewControllerOnTop(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.window?.rootViewController?.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    //MARK: - Handling NSUserActivity
    //UIKit will call this when handoff data becomes available. Within FAST this will also be called when a scene should resume using an activity object.
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        NSLog("Scene continue user activity: \(userActivity.title ?? "") (\(userActivity.activityType))")
        
        //Set the correct rootViewController
        switch userActivity.activityType {
        case Globals.UserActivity.eventSelection:
            //Open up the team list table view
            if let eventKey = userActivity.userInfo?["eventKey"] as? String, let teamListSplitVC = window?.rootViewController as? FASTMainSplitViewController {
                teamListSplitVC.teamListTableVC.preferSelection(ofEvent: eventKey)
            }
        case Globals.UserActivity.viewTeamDetail:
            if let eventKey = userActivity.userInfo?["eventKey"] as? String, let teamKey = userActivity.userInfo?["teamKey"] as? String, let teamListSplitVC = window?.rootViewController as? FASTMainSplitViewController {
                teamListSplitVC.teamListTableVC.preferSelection(ofEvent: eventKey)
                teamListSplitVC.teamDetailVC.load(forInput: (teamKey, eventKey))
            }
        case NSUserActivityTypeBrowsingWeb:
            if let url = userActivity.webpageURL, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                if let inviteId = urlComponents.queryItems?.first(where: {$0.name == "id"})?.value, let secretCode = urlComponents.queryItems?.first(where: {$0.name == "secretCode"})?.value {
                    let confirmVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "confirmJoinScoutingTeam") as! ConfirmJoinScoutingTeamViewController
                    confirmVC.load(forInviteId: inviteId, andCode: secretCode)
                    self.presentViewControllerOnTop(confirmVC, animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        NSLog("Requested state restoration activity for scene. \(scene.userActivity?.description ?? "No such activity.")")
        return scene.userActivity
    }
}
