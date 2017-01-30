//
//  GameFieldLocationViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/29/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import AVFoundation

protocol GameFieldLocationDelegate {
    func selectedRelativePoint(point: CGPoint)
    func canceled()
}

class GameFieldLocationViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var invisibleView: UIView!
    
    var delegate: GameFieldLocationDelegate?
    var selectedRelativePoint: CGPoint? {
        didSet {
            if selectedRelativePoint != nil {
                doneButton.isEnabled = true
            } else {
                doneButton.isEnabled = false
            }
        }
    }
    var placedPoint: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let new = placedPoint {
                invisibleView.addSubview(new)
            }
        }
    }
    
    let ssDataManager = SSDataManager.currentSSDataManager()!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if ssDataManager.scoutedMatchPerformance.allianceColor == TeamMatchPerformance.Alliance.Red.rawValue {
            imageView.image = UIImage(named: "Red Boiler Map")
        } else if ssDataManager.scoutedMatchPerformance.allianceColor == TeamMatchPerformance.Alliance.Blue.rawValue {
            imageView.image = UIImage(named: "Blue Boiler Map")
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "StandsScoutingEnded"), object: nil, queue: nil) {_ in
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadInvisibleView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) {_ in self.reloadInvisibleView()}
    }
    
    func reloadInvisibleView() {
        let newFrame = AVMakeRect(aspectRatio: imageView.image!.size, insideRect: imageView.frame)
        invisibleView.frame = newFrame
    }
    
    func reloadPointView() {
        if let relativePoint = selectedRelativePoint {
            let point = translateRelativePointToPoint(relativePoint: relativePoint, toSize: invisibleView.frame.size)
            let newPointView = UIView(frame: CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10))
            newPointView.layer.cornerRadius = 5
            newPointView.backgroundColor = UIColor.blue
            placedPoint = newPointView
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.selectedRelativePoint(point: selectedRelativePoint!)
        performSegue(withIdentifier: "rewindToFuel", sender: self)
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.canceled()
        performSegue(withIdentifier: "rewindToFuel", sender: self)
    }
    
    @IBAction func tappedOnImage(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: invisibleView)
        
        //Record the point
        selectedRelativePoint = translatePointToRelativePoint(point: location, withCurrentSize: invisibleView.frame.size)
        
        //Create a point and place it on the screen
        reloadPointView()
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
