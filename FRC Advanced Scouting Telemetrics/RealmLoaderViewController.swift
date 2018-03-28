//
//  RealmLoaderViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/11/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics

///This is used right after login to load the realm
class RealmLoaderViewController: UIViewController {
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var downloadProgressToken: NotificationToken?
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadProgressView.setProgress(0, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.downloadProgressToken = RealmController.realmController.currentSyncUser?.session(for: RealmController.realmController.syncedRealmURL!)?.addProgressNotification(for: .download, mode: .reportIndefinitely) {[weak self] progress in
            
            DispatchQueue.main.async {
                self?.downloadProgressView.setProgress(Float(progress.fractionTransferred), animated: true)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        downloadProgressToken?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func realmAsyncOpenHandler(error: Error?) {
        if let error = error {
            let alert = UIAlertController(title: "Unable to Open", message: "An error occured opening the scouted data. Please try again with a stable internet connection. If this happens again please contact frcfastapp@gmail.com. Error: \(error)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in self.cancelSyncing()}))
            self.present(alert, animated: true, completion: nil)
        } else {
            didCompleteSync()
        }
    }
    
    func didCompleteSync() {
        //Move on to the Team List
        
        let teamList = storyboard?.instantiateInitialViewController()
        self.view.window?.rootViewController = teamList
    }
    
    func cancelSyncing() {
        downloadProgressToken?.invalidate()
        
        RealmController.realmController.closeSyncedRealms()
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        cancelSyncing()
        
        Answers.logCustomEvent(withName: "Canceled Loading Realm on Log In", customAttributes: nil)
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
