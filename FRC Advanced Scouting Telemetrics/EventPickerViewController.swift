//
//  EventPickerViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/15/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class EventPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
	@IBOutlet weak var eventPicker: UIPickerView!
	
	var delegate: EventSelection?
	var dataManager = DataManager()
	private var events: [Event]?
	private var currentEvent: Event?
	private var chosenEvent: Event?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		eventPicker.dataSource = self
		eventPicker.delegate = self
		
		//Load all the events
		events = dataManager.events()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		currentEvent = delegate?.currentEvent()
		
		if let current = currentEvent {
			let index = (events?.index(of: current))! + 1
			eventPicker.selectRow(index, inComponent: 0, animated: false)
			pickerView(eventPicker, didSelectRow: index, inComponent: 0)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		delegate?.eventSelected(chosenEvent)
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return events!.count + 1
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch row {
		case 0:
			return "All Teams (Default)"
		default:
			return events![row-1].name
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if row == 0 {
			chosenEvent = nil
		} else {
			chosenEvent = events![row-1]
		}
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol EventSelection {
	func eventSelected(_ event: Event?)
	func currentEvent() -> Event?
}
