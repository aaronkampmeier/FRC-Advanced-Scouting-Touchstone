//
//  OnboardingPageViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/23/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit

let onboardingCompletedStatusKey = "onboardingCompletionStatus"

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var onboardingVCs = [UIViewController]()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        onboardingVCs = [viewController(forOnboardingIndex: 0)!, viewController(forOnboardingIndex: 1)!, viewController(forOnboardingIndex: 2)!, viewController(forOnboardingIndex: 3)!, viewController(forOnboardingIndex: 4)!]
        
        setViewControllers([onboardingVCs.first!], direction: .forward, animated: true, completion: nil)
        
        self.dataSource = self
        
//        addStationaryCyborgCat()
        
        view.backgroundColor = UIColor.white
    }
    
    func addStationaryCyborgCat() {
        //Set the cyborg cat subview
        let cyborgCatImageView = UIImageView(image: #imageLiteral(resourceName: "Cyborg Cat Simple"))
        cyborgCatImageView.contentMode = UIViewContentMode.scaleToFill
        cyborgCatImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cyborgCatImageView)
        let imageWidth: CGFloat = 260
        cyborgCatImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cyborgCatImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        cyborgCatImageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true
        cyborgCatImageView.heightAnchor.constraint(equalToConstant: imageWidth / 1.2).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewController(forOnboardingIndex index: Int) -> UIViewController? {
        switch index {
        case 0:
            return storyboard?.instantiateViewController(withIdentifier: "onboarding0")
        case 1:
            return storyboard?.instantiateViewController(withIdentifier: "onboarding1")
        case 2:
            return storyboard?.instantiateViewController(withIdentifier: "onboarding2")
        case 3:
            return storyboard?.instantiateViewController(withIdentifier: "onboarding3")
        case 4:
            return storyboard?.instantiateViewController(withIdentifier: "onboardingPathChooser")
        default:
            return nil
        }
    }
    
//    func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        return 5
//    }
//
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        return 0
//    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = onboardingVCs.index(of: viewController) else {
            return nil
        }
        
        //Check it's not the first
        if currentIndex < onboardingVCs.count && currentIndex > 0 {
            return onboardingVCs[currentIndex - 1]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = onboardingVCs.index(of: viewController) else {
            return nil
        }
        
        if currentIndex < onboardingVCs.count - 1 && currentIndex >= 0 {
            return onboardingVCs[currentIndex + 1]
        } else {
            return nil
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
