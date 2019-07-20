//
//  SSGameStateViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/11/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import UIKit
import SSBouncyButton

enum SSStateGameSection {
    case Start
    case End
}

///Used for tracking start state and end state per the Stands Scouting Model
class SSGameStateViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var ssDataManager = SSDataManager.currentSSDataManager
    
    ///Set before loading view
    var requestedStates = [GameState]()
    var section: SSStateGameSection?
    
    let transition = OptionSelectorAnimator()
    let layout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = layout
        
        collectionView.allowsSelection = false
//        collectionView.setCollectionViewLayout(SSGameStateCollectionViewLayout(), animated: false)
        
        if let section = section {
            self.set(gameSection: section)
        }
    }
    
    func set(gameSection: SSStateGameSection) {
        self.section = gameSection
        
        if isViewLoaded {
            switch gameSection {
            case .Start:
                requestedStates = ssDataManager?.model?.startState ?? []
            case .End:
                requestedStates = ssDataManager?.model?.endState ?? []
            }
            
            collectionView.reloadData()
        }
    }
    
    @objc func buttonPressed(_ sender: SSButton) {
        //Show the option vc
        let optionSelector = storyboard?.instantiateViewController(withIdentifier: "optionSelector") as! OptionSelectorViewController
        let requestedState = requestedStates.first(where: {$0.key == sender.key})
        optionSelector.load(withPrompt: "Select \(requestedState?.name ?? "?")", andOptions: requestedState?.options ?? [], selectionCallback: { (key) in
            let option = requestedState?.options.first(where: {$0.key == key})
            sender.setOptionLabel(forLabel: option?.name)
            
            self.ssDataManager?.setState(value: key, forKey: requestedState?.key ?? "", inSection: self.section!)
        })

        optionSelector.transitioningDelegate = self
        optionSelector.modalPresentationStyle = .custom
        self.present(optionSelector, animated: true, completion: nil)
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

extension SSGameStateViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return requestedStates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let requestedState = requestedStates[indexPath.item]
        let label = cell.viewWithTag(1) as! UILabel
        let button = cell.viewWithTag(2) as! SSButton
        
        label.text = "Select \(requestedState.name)"
        button.setTitle("Select", for: .normal)
        button.tintColor = UIColor.orange
        button.key = requestedState.key
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 0.0
        let height: CGFloat = 165
        if view.traitCollection.horizontalSizeClass == .compact {
            //For compact, we want a vertical list
            width = view.frame.width - 10
        } else {
            //We want a more spread out list
            width = view.frame.width / 2 - 10
            
            if width > 450 {
                width = 450
            }
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //Inset to make everything centered on screen
        let top: CGFloat = 0
        let left: CGFloat = 0
        let right: CGFloat = 0
        let bottom: CGFloat = 0

//        if collectionView.contentSize.height < view.frame.height {
//            //Inset stuff
//            let diff = view.frame.height - collectionView.contentSize.height
//            top = diff / 2
//            bottom = diff / 2
//        }
//
//        if collectionView.contentSize.width < view.frame.width {
//            let diff = view.frame.width - collectionView.contentSize.width
//
//            right = diff / 2
//            left = diff / 2
//        }

        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

class SSGameStateCollectionViewLayout: UICollectionViewLayout {
    
}

extension SSGameStateViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return OptionSelectorPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class SSButton: SSBouncyButton {
    let optionLabel: UILabel
    let nameLabel: UILabel
    
    var key: String?
    
    override init(frame: CGRect) {
        self.optionLabel = UILabel()
        self.nameLabel = UILabel()
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.optionLabel = UILabel()
        self.nameLabel = UILabel()
        super.init(coder: aDecoder)
    }
    
    func setOptionLabel(forLabel label: String?) {
        if let label = label {
            isSelected = true
            
            optionLabel.numberOfLines = 0
            optionLabel.textAlignment = .center
            optionLabel.textColor = UIColor.white //self.tintColor
            optionLabel.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
            
            nameLabel.textAlignment = .center
            nameLabel.textColor = UIColor.white
            nameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            
            //Now use a new label
            optionLabel.text = label
            
//            NSLayoutConstraint.activate([])
//            optionLabel.frame = CGRect(x: (self.frame.width / 2) - (width / 2), y: (self.frame.height / 2) - (height / 2), width: width, height: height)
            addSubview(optionLabel)
            
            //Move the title text down a bit
//            var frame = CGRect(x: self.titleLabel!.frame.origin.x, y: optionLabel.frame.origin.y + 100, width: width, height: 15)
////            frame?.origin.y = (self.frame.height / 2) + 30
//            self.titleLabel?.font = self.titleLabel?.font.withSize(12)
//            self.titleLabel?.frame = frame
            setTitle(nil, for: .normal)
            
            //Use a new label for the description
            nameLabel.text = titleLabel?.text
//            let frame = CGRect(x: self.titleLabel!.frame.origin.x, y: optionLabel.frame.origin.y + 100, width: width, height: 15)
//            nameLabel.frame = frame
//            addSubview(nameLabel)
            
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            optionLabel.translatesAutoresizingMaskIntoConstraints = false
            
            //Use constraints to lay out the views
            NSLayoutConstraint.activate([optionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor), optionLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)])
//            NSLayoutConstraint.activate([nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor), nameLabel.topAnchor.constraint(equalTo: optionLabel.bottomAnchor, constant: 5)])
        }
    }
}
