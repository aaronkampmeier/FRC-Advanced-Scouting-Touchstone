//
//  SyncStatusViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/18/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit
import RealmSwift

class SyncStatusViewController: UIViewController {
    @IBOutlet weak var uploadProgressView: UIProgressView!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var uploadCheckView: UIImageView!
    @IBOutlet weak var downloadCheckView: UIImageView!
    
    var downloadProgressObserver: NotificationToken?
    var uploadProgressObserver: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        downloadProgressObserver = RealmController.realmController.currentSyncUser?.session(for: RealmController.realmController.syncedRealmURL!)?.addProgressNotification(for: .download, mode: .reportIndefinitely) {[weak self] progress in
            DispatchQueue.main.async {
                if progress.isTransferComplete {
                    self?.downloadProgressView.isHidden = true
                    self?.downloadCheckView.isHidden = false
                } else {
                    self?.downloadCheckView.isHidden = true
                    self?.downloadProgressView.isHidden = false
                    
                    self?.downloadProgressView.setProgress(Float(progress.fractionTransferred), animated: true)
                    NSLog("Transferrable Bytes: \(progress.transferrableBytes), Transferred: \(progress.transferredBytes)")
                }
            }
        }
        
        uploadProgressObserver = RealmController.realmController.currentSyncUser?.session(for: RealmController.realmController.syncedRealmURL!)?.addProgressNotification(for: .upload, mode: .reportIndefinitely) {[weak self] progress in
            DispatchQueue.main.async {
                if progress.isTransferComplete {
                    self?.uploadProgressView.isHidden = true
                    self?.uploadCheckView.isHidden = false
                } else {
                    self?.uploadProgressView.isHidden = false
                    self?.uploadCheckView.isHidden = true
                    
                    self?.uploadProgressView.setProgress(Float(progress.fractionTransferred), animated: true)
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        uploadProgressObserver?.invalidate()
        downloadProgressObserver?.invalidate()
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
