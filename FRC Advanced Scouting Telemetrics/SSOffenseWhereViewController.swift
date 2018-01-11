//
//  SSOffenseWhereViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/18/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import SSBouncyButton
import SpriteKit
import UICircularProgressRing

protocol WhereDelegate {
    func shouldSelect(_ whereVC: SSOffenseWhereViewController, id: String, handler: @escaping (Bool)->Void)
    func selected(_ whereVC: SSOffenseWhereViewController, id: String)
}

protocol FASTSSButtonable: CustomStringConvertible {
    var rawValue: String {get}
}

extension FASTSSButtonable {
    func button(_ color: UIColor) -> SSOffenseWhereViewController.Button {
        return SSOffenseWhereViewController.Button(title: self.description, color: color, id: self.rawValue)
    }
}

class SSOffenseWhereViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView?
    @IBOutlet weak var prompt: UILabel!
    @IBOutlet weak var timerView: UICircularProgressRingView!
    
    var promptText: String?
    
    fileprivate var buttons: [Button] = [] {
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
    fileprivate var ssBouncyButtons = [SSBouncyButton]()
    fileprivate var cushionTime: TimeInterval = 0
    
    var delegate: WhereDelegate?
    var selectedButton: Button?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.isHidden = true
        
        //Reload the views in the stack view
        let buttons = self.buttons
        self.buttons = buttons
        
        if let text = promptText {
            self.prompt.text = text
        }
        
        timerView.maxValue = 3
        timerView.innerRingColor = UIColor.blue
        timerView.outerRingColor = buttons.first?.color ?? UIColor.blue
        timerView.outerRingWidth = 2
        timerView.innerRingWidth = 1
        
        timerView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedTimer(_ sender: UITapGestureRecognizer) {
        self.hide()
        delegate?.selected(self, id: selectedButton!.id)
        currentScheduledTask?.cancel()
    }
    
    func setUpWithButtons(_ buttons: [Button], time: TimeInterval) {
        self.buttons = buttons
        self.cushionTime = time
    }
    
    func setPrompt(to prompt: String) {
        promptText = prompt
    }
    
    func reset() {
        for button in ssBouncyButtons {
            button.isSelected = false
        }
        timerView.setProgress(value: 0, animationDuration: 0)
        timerView.isHidden = true
    }
    
    func show() {
        reset()
        self.view.isHidden = false
    }
    
    func hide() {
        self.view.isHidden = true
    }
    
    var currentScheduledTask: DispatchWorkItem?
    @objc func didSelectButton(_ sender: SSBouncyButton) {
        for button in ssBouncyButtons {
            button.isSelected = false
        }
        
        sender.isSelected = !sender.isSelected
        let index = buttons.index() {button in
            return button.title == sender.title(for: .normal)
        }
        let selectedButton = buttons[index!]
        
        delegate?.shouldSelect(self, id: selectedButton.id) {self.select(sender, shouldSelect: $0)}
    }
    
    func select(_ buttonToSelect: SSBouncyButton, shouldSelect: Bool) {
        let index = buttons.index() {button in
            return button.title == buttonToSelect.title(for: .normal)
        }
        selectedButton = buttons[index!]
        
        if shouldSelect {
            buttonToSelect.isSelected = true
            
            timerView.isHidden = false
            timerView.setProgress(value: 0, animationDuration: 0)
            timerView.setProgress(value: 3, animationDuration: 3)
            
            currentScheduledTask?.cancel()
            
            currentScheduledTask = DispatchWorkItem {
                self.hide()
                self.delegate?.selected(self, id: self.selectedButton!.id)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + cushionTime, execute: currentScheduledTask!)
        } else {
            buttonToSelect.isSelected = false
        }
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
