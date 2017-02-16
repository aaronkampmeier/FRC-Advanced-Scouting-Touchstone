//
//  TeamInfoScrollView.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/14/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class TeamInfoScrollView: UIScrollView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.first!.point(inside: point, with: event)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
