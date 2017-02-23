//
//  FieldLocationDisplayViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/21/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import AVFoundation

protocol FieldLocationDisplayDataSource {
    func allowsMultiplePoints() -> Bool
    func allowsAddition() -> Bool
//    func allowsRemoval() -> Bool
    
    func fieldImage(forFieldLocationDisplayController fieldLocationDisplayVC: FieldLocationDisplayViewController) -> UIImage
    func allPoints(forFieldLocationDisplayController fieldLocationDisplayVC: FieldLocationDisplayViewController) -> [CGPoint]
}

protocol FieldLocationDisplayDelegate {
    func addedPoint(withRelativeLocation relativeLocation: CGPoint)
//    func removedPoint(withRelativeLocation relativeLocation: CGPoint)
}

class FieldLocationDisplayViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var invisibleView: UIView!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var points: [CGPoint] = [] {
        willSet {
            if !(dataSource?.allowsMultiplePoints() ?? false) {
                points.removeAll()
                reloadPoints()
            }
        }
        
        didSet {
            reloadPoints()
        }
    }
    var placedViews: [UIView] = [] {
        didSet {
            for oldPoint in oldValue {
                oldPoint.removeFromSuperview()
            }
            
            for newPoint in placedViews {
                invisibleView.addSubview(newPoint)
            }
        }
    }
    
    var delegate: FieldLocationDisplayDelegate?
    var dataSource: FieldLocationDisplayDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Set up
        imageView.image = dataSource?.fieldImage(forFieldLocationDisplayController: self)
        points = dataSource?.allPoints(forFieldLocationDisplayController: self) ?? []
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        reloadInvisibleView()
        reloadPoints()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) {_ in self.reloadInvisibleView()}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadPoints() {
        placedViews = []
        for point in points {
            let actualPoint = translateRelativePointToPoint(point, toSize: invisibleView.frame.size)
            let pointView = UIView(frame: CGRect(x: actualPoint.x - 5, y: actualPoint.y - 5, width: 10, height: 10))
            
            pointView.layer.cornerRadius = 5
            pointView.backgroundColor = UIColor.blue
            placedViews.append(pointView)
        }
    }
    
    func reloadInvisibleView() {
        let newFrame = AVMakeRect(aspectRatio: imageView.image!.size, insideRect: imageView.frame)
        invisibleView.frame = newFrame
    }
    
    @IBAction func didTapOnInvisibleView(_ sender: UITapGestureRecognizer) {
        if dataSource?.allowsAddition() ?? false {
            let location = sender.location(in: invisibleView)
            
            let relativePoint = translatePointToRelativePoint(location, withCurrentSize: invisibleView.frame.size)
            points.append(relativePoint)
            delegate?.addedPoint(withRelativeLocation: relativePoint)
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
