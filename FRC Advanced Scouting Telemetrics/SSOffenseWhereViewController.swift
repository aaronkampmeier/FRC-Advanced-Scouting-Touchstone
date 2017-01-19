//
//  SSOffenseWhereViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/18/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import SSBouncyButton

protocol WhereDelegate {
    func selected(_ whereVC: SSOffenseWhereViewController, id: Int)
}

class SSOffenseWhereViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView?
    
    private var buttons: [Button] = [] {
        didSet {
            for subview in stackView?.arrangedSubviews ?? [UIView]() {
                stackView?.removeArrangedSubview(subview)
            }
            for (index, button) in buttons.enumerated() {
                let bouncyButton = SSBouncyButton()
                bouncyButton.tintColor = button.color
                bouncyButton.setTitle(button.title, for: .normal)
                bouncyButton.addTarget(self, action: #selector(didSelectButton(_:)), for: .touchUpInside)
                stackView?.insertArrangedSubview(bouncyButton, at: index)
            }
        }
    }
    private var ssBouncyButtons = [SSBouncyButton]()
    private var cushionTime: TimeInterval = 0
    
    var delegate: WhereDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.isHidden = true
        
        //Reload the views in the stack view
        let buttons = self.buttons
        self.buttons = buttons
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpWithButtons(buttons: [Button], time: TimeInterval) {
        self.buttons = buttons
        self.cushionTime = time
    }
    
    func reset() {
        for button in ssBouncyButtons {
            button.isSelected = false
        }
    }
    
    func show() {
        reset()
        self.view.isHidden = false
    }
    
    func hide() {
        self.view.isHidden = true
    }
    
    func didSelectButton(_ sender: SSBouncyButton) {
        sender.isSelected = !sender.isSelected
        let index = buttons.index() {button in
            return button.title == sender.title(for: .normal)
        }
        let selectedButton = buttons[index!]
        delegate?.selected(self, id: selectedButton.id)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.hide()
        }
    }
    
    struct Button {
        var color: UIColor
        var title: String
        var id: Int
        
        init(title: String, color: UIColor, id: Int) {
            self.title = title
            self.color = color
            self.id = id
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
