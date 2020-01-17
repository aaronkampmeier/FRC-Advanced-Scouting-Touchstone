//
//  JoinScoutingTeamTableViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/6/20.
//  Copyright © 2020 Kampfire Technologies. All rights reserved.
//

import UIKit
import AVFoundation
import Crashlytics
import FirebaseAnalytics

class JoinScoutingTeamTableViewController: UITableViewController, ScannerViewControllerDelegate {

    var qrCodeScannerVC: ScannerViewController?
    
    var enteredInviteId: String?
    var enteredCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        navigationItem.prompt = "Scan the invitation QR code or enter the details below"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join", style: .done, target: self, action: #selector(donePressed))
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.systemOrange]
            navigationItem.standardAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
        
        qrCodeScannerVC = ScannerViewController()
        qrCodeScannerVC?.delegate = self
        let height = self.view.frame.height / 3
        qrCodeScannerVC?.view.frame = CGRect(x: 0, y: 0, width: 0, height: height)
        tableView.tableHeaderView = qrCodeScannerVC?.view
    }
    
    @objc func donePressed() {
        
        if let inviteId = enteredInviteId, let code = enteredCode {
            let confirmVC = storyboard?.instantiateViewController(withIdentifier: "confirmJoinScoutingTeam") as! ConfirmJoinScoutingTeamViewController
            confirmVC.load(forInviteId: inviteId, andCode: code)
            if let presentingVC = self.presentingViewController {
                self.dismiss(animated: true) {
                    presentingVC.present(confirmVC, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func failed() {
        CLSNSLogv("Failed to scan for QR codes", getVaList([]))
        tableView.tableHeaderView = nil
    }
    
    //Returns if the qr reader should keep scanning
    func found(code: String) -> Bool {
        CLSNSLogv("Found QR code: \(code)", getVaList([]))
        if let urlComponents = URLComponents(string: code) {
            if urlComponents.host == "frcfastapp.com" && urlComponents.path == "/invite" {
                if let inviteId = urlComponents.queryItems?.first(where: {$0.name == "id"})?.value, let secretCode = urlComponents.queryItems?.first(where: {$0.name == "secretCode"})?.value {
                    self.enteredInviteId = inviteId
                    self.enteredCode = secretCode
                    self.donePressed()
                    Globals.recordAnalyticsEvent(eventType: "scan_invite_code")
                }
                return false
                
            }
        }
        return true
    }

    // MARK: - Table view data source
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CreateScoutingTeamTableViewCell

        switch indexPath.row {
        case 0:
            cell.label.text = "Invite ID:"
            cell.textField.placeholder = "WERT5G7Y3"
            cell.registerTextFieldHandler { (newText) -> Bool in
                self.enteredInviteId = newText
                return newText?.count == 9 && newText?.isAlphanumeric ?? false
            }
        case 1:
            cell.label.text = "Secret Code:"
            cell.textField.placeholder = "WO4-3E2"
            cell.registerTextFieldHandler { (newText) -> Bool in
                self.enteredCode = newText
                return newText?.count == 7
            }
        default:
            break
        }

        return cell
    }

}

protocol ScannerViewControllerDelegate {
    func failed()
    func found(code: String) -> Bool
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var delegate: ScannerViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = .black
        }
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession?.canAddInput(videoInput) ?? false) {
            captureSession?.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession?.canAddOutput(metadataOutput) ?? false) {
            captureSession?.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        if let captureSession = captureSession {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.frame = view.layer.bounds
            previewLayer?.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer!)
            
            captureSession.startRunning()
        }
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
         
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer?.frame = view.layer.bounds
    }

    func failed() {
        delegate?.failed()
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession?.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession?.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        

        if let metadataObject = metadataObjects.first {
            if metadataObject.type == AVMetadataObject.ObjectType.qr {
                // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
                let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObject)
                qrCodeFrameView?.frame = barCodeObject!.bounds
                
                
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                if !found(code: stringValue) {
                    captureSession?.stopRunning()
                }
            }
        }
    }

    func found(code: String) -> Bool {
        return delegate?.found(code: code) ?? false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}
