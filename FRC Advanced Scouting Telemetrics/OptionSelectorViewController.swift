//
//  OptionSelectorViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/13/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import UIKit
import SSBouncyButton

struct OptionSelectorButtonInput {
    let color: UIColor
    let label: String
    let key: String
    
    init(color: UIColor, label: String, key: String) {
        self.color = color
        self.label = label
        self.key = key
    }
}

class OptionSelectorViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    var callback: ((String) -> Void)?
    var options = [SSOption]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func load(withPrompt prompt: String, andOptions options: [SSOption], selectionCallback: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            while self.isViewLoaded == false {
                
            }
            
            for subview in self.stackView?.arrangedSubviews ?? [UIView]() {
                self.stackView?.removeArrangedSubview(subview)
            }
            
            self.callback = selectionCallback
            self.titleLabel.text = prompt
            
            self.options = options
            for (index, option) in options.enumerated() {
                let button = SSBouncyButton()
                if let color = option.color {
                    button.tintColor = UIColor(hexString: color)
                } else {
                    button.tintColor = UIColor.purple
                }
                button.setTitle(option.name, for: .normal)
                button.addTarget(self, action: #selector(self.buttonSelected(_:)), for: .touchUpInside)
                
                //Add it to the stack view
                self.stackView.insertArrangedSubview(button, at: index)
            }
        }
    }
    
    var workItem: DispatchWorkItem?
    @objc func buttonSelected(_ sender: SSBouncyButton) {
        sender.isSelected = true
        let button = options.first(where: {$0.name == sender.title(for: .normal)})
        
        workItem?.cancel()
        workItem = DispatchWorkItem  {
            self.callback?(button?.key ?? "")
            self.dismiss(animated: true, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: workItem!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//From https://www.hackingwithswift.com/example-code/uicolor/how-to-convert-a-hex-color-to-a-uicolor
extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}


///Presentation of OptionSelector
class OptionSelectorPresentationController: UIPresentationController {
    let blurEffectView: UIVisualEffectView
    var tapGestureRecognizer: UIGestureRecognizer!
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.isUserInteractionEnabled = true
        blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        //Make the view only cover part of the screen
        let currentFrame = containerView?.frame ?? CGRect.zero
        
        var newWidth: CGFloat = 0
        var newHeight: CGFloat = 0
        
        if presentedViewController.traitCollection.verticalSizeClass == .compact {
            newHeight = currentFrame.height - 20
            
            if presentedViewController.traitCollection.horizontalSizeClass == .regular {
                //Regular width, compact height
                newWidth = currentFrame.width - 75
            } else {
                //Compact, compact
                newWidth = currentFrame.width - 75
            }
        } else {
            if presentedViewController.traitCollection.horizontalSizeClass == .regular {
                //Regular, regular
                newHeight = currentFrame.height * (2 / 3)
                newWidth = currentFrame.width * (1 / 3)
            } else {
                //Regular height, compact width
                newHeight = currentFrame.height - 180
                newWidth = currentFrame.width - 50
            }
        }
        
        //If new height is bigger than max height, set to max height instead
        if newHeight > 800 {
            newHeight = 800
        }
        
        var newFrame = CGRect(x: (currentFrame.width - newWidth) / 2, y: (currentFrame.height - newHeight) / 2, width: newWidth, height: newHeight)
        
        return newFrame
    }
    
    override func dismissalTransitionWillBegin() {
        
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.removeFromSuperview()
        })
    }
    override func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        self.containerView?.addSubview(blurEffectView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 1
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in

        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.layer.cornerRadius = 20
        presentedView?.layer.masksToBounds = true
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
    }
    
    @objc func dismiss() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}

class OptionSelectorAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.5
    var presenting = true
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if presenting {
            let toView = transitionContext.view(forKey: .to)!
            containerView.addSubview(toView)
            
            toView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            toView.alpha = 0
            UIView.animate(withDuration: duration - 0.3) {
                toView.alpha = 1
            }
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                toView.transform = CGAffineTransform.identity
            }) { (_) in
                transitionContext.completeTransition(true)
            }
        } else {
            let fromViewController = transitionContext.viewController(forKey: .from)!
            
            //Snapshot it
            let snapshotFrom = fromViewController.view.snapshotView(afterScreenUpdates: false)!
            snapshotFrom.frame = fromViewController.view.frame
            containerView.addSubview(snapshotFrom)
            
            fromViewController.view.removeFromSuperview()
            
            snapshotFrom.transform = CGAffineTransform.identity
            snapshotFrom.alpha = 1.0
            
            UIView.animate(withDuration: duration - 0.3) {
                snapshotFrom.alpha = 0
            }
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                snapshotFrom.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }) { (_) in
                snapshotFrom.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
        
        
    }
    
    
}
