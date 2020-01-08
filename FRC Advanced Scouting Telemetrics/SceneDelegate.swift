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
            //User activity restoration logic
            if let activity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
                self.scene(scene, continue: activity)
            } else {
                self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC")
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
        
        if let restorationActivity = session.stateRestorationActivity {
            //TODO: AJNSOJ
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
    
    //MARK: - Handling NSUserActivity
    //UIKit will call this when handoff data becomes available. Within FAST this will also be called when a scene should resume using an activity object.
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        NSLog("Scene continue user activity: \(userActivity.title ?? "")")
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        //Set the correct rootViewController
        switch userActivity.activityType {
        case Globals.UserActivity.eventSelection:
            //Open up the team list table view
            let eventKey = userActivity.userInfo?["eventKey"] as? String
            let teamListSplitVC = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC") as! TeamListSplitViewController
            self.window?.rootViewController = teamListSplitVC
            teamListSplitVC.teamListTableVC.selectedEventKey = eventKey
        case Globals.UserActivity.viewTeamDetail:
            let eventKey = userActivity.userInfo?["eventKey"] as? String
            let teamKey = userActivity.userInfo?["teamKey"] as? String
            let teamListSplitVC = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC") as! TeamListSplitViewController
//            teamListSplitVC.teamListTableVC.selectedEventKey = eventKey
            self.window?.rootViewController = teamListSplitVC
            teamListSplitVC.teamListTableVC.eventSelected(eventKey)
            Globals.appSyncClient?.fetch(query: ListTeamsQuery(eventKey: eventKey ?? ""), cachePolicy: .returnCacheDataElseFetch, resultHandler: { (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "RestoreTeamFromList", result: result, error: error) {
                    let team = result?.data?.listTeams?.first(where: {$0?.key == teamKey})??.fragments.team
                    teamListSplitVC.teamListTableVC.selectedTeam = team
                }
            })
        default:
            break
        }
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        NSLog("Requested state restoration activity for scene. \(scene.userActivity?.description ?? "No such activity.")")
        return scene.userActivity
    }
}
