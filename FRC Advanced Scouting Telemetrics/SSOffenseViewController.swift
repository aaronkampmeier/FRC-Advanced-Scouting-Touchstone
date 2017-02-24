//
//  SSOffense.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/17/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import SSBouncyButton

class SSOffenseViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewWidth: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.view.traitCollection.horizontalSizeClass == .compact {
            viewWidth.constant = scrollView.frame.width
        } else {
            viewWidth.constant = scrollView.frame.width / 2
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        
        pageControl.currentPage = Int(currentPage)
    }
}
