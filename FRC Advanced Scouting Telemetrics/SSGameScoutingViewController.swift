//
//  SSGameScoutingViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/28/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit

class SSGameScoutingViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let layout = UICollectionViewFlowLayout()
    let animationController = OptionSelectorAnimator()
    var ssDataManager: SSDataManager?
    
    var model: StandsScoutingModel? {
        return ssDataManager?.model?.standsScouting
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.allowsSelection = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func buttonPressed(_ sender: SSButton) {
        //Show the option selector
        let optionSelector = storyboard?.instantiateViewController(withIdentifier: "optionSelector") as! OptionSelectorViewController
        
        let gameAction = model?.gameActions.first(where: {$0.key == sender.key})
        optionSelector.load(withPrompt: "\(gameAction?.name ?? "")", andOptions: gameAction?.subOptions ?? [SSOption(name: "\(gameAction?.name ?? "")", key: "", color: nil)]) { (key) in
            //Save it
            self.ssDataManager?.addTimeMarker(event: gameAction!.key, subOption: key)
        }
        
        optionSelector.transitioningDelegate = self
        optionSelector.modalPresentationStyle = .custom
        present(optionSelector, animated: true, completion: nil)
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

extension SSGameScoutingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.gameActions.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let gameAction = model!.gameActions[indexPath.item]
        let button = cell.viewWithTag(1) as! SSButton
        
        button.setTitle("\(gameAction.name)", for: .normal)
        button.tintColor = UIColor.orange
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        button.key = gameAction.key
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 0.0
        let height: CGFloat = 80
        if view.traitCollection.horizontalSizeClass == .compact {
            //For compact, we want a vertical list
            width = view.frame.width - 30
        } else {
            //We want a more spread out list
            width = view.frame.width / 2 - 10
            
            if width > 300 {
                width = 300
            }
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}


extension SSGameScoutingViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.presenting = true
        return animationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.presenting = false
        return animationController
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return OptionSelectorPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
