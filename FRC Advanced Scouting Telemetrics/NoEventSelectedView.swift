//
//  NoEventSelectedView.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/11/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit

class NoEventSelectedView: UIView {
    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("NoEventSelected", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
