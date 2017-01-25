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
    func selected(_ whereVC: SSOffenseWhereViewController, id: String)
}

protocol FASTSSButtonable: CustomStringConvertible {
    var rawValue: String {get}
}

extension FASTSSButtonable {
    func button(color: UIColor) -> SSOffenseWhereViewController.Button {
        return SSOffenseWhereViewController.Button(title: self.description, color: color, id: self.rawValue)
    }
}

class SSOffenseWhereViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView?
    
    private var buttons: [Button] = [] {
        didSet {
            ssBouncyButtons.removeAll()
            for subview in stackView?.arrangedSubviews ?? [UIView]() {
                stackView?.removeArrangedSubview(subview)
            }
            for (index, button) in buttons.enumerated() {
                let bouncyButton = SSBouncyButton()
                bouncyButton.tintColor = button.color
                bouncyButton.setTitle(button.title, for: .normal)
                bouncyButton.addTarget(self, action: #selector(didSelectButton(_:)), for: .touchUpInside)
                
                ssBouncyButtons.append(bouncyButton)
                
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
    
    var currentScheduledTask: DispatchWorkItem?
    func didSelectButton(_ sender: SSBouncyButton) {
        for button in ssBouncyButtons {
            button.isSelected = false
        }
        
        sender.isSelected = !sender.isSelected
        let index = buttons.index() {button in
            return button.title == sender.title(for: .normal)
        }
        let selectedButton = buttons[index!]
        
        currentScheduledTask?.cancel()
        
        currentScheduledTask = DispatchWorkItem {
            self.hide()
            self.delegate?.selected(self, id: selectedButton.id)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cushionTime, execute: currentScheduledTask!)
    }
    
    struct Button {
        var color: UIColor
        var title: String
        var id: String
        
        init(title: String, color: UIColor, id: String) {
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
