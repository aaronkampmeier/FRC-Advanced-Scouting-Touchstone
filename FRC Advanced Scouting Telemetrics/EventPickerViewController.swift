//
//  EventPickerViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/15/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import RealmSwift

class EventPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var eventPicker: UIPickerView!
    
    @IBOutlet weak var introText: UILabel!
    var delegate: EventSelection?
    fileprivate var events: Results<Event>?
    fileprivate var currentEvent: Event?
    fileprivate var chosenEvent: Event?
    
    fileprivate var eventUpdaterToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        eventPicker.dataSource = self
        eventPicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Load all the events
        events = RealmController.realmController.generalRealm.objects(Event.self)
        
        if events?.count == 0 {
            introText.isHidden = false
        } else {
            introText.isHidden = true
        }
        
        currentEvent = delegate?.currentEvent()
        
        if let current = currentEvent {
            let index = (events?.index(of: current))!
            eventPicker.selectRow(index, inComponent: 0, animated: false)
            self.chosenEvent = events![index]
        } else {
            self.chosenEvent = nil
        }
        
        eventUpdaterToken = events?.observe {[weak self] collectionChange in
            switch collectionChange {
            case .update:
                self?.eventPicker.reloadAllComponents()
                self?.chosenEvent = nil
            default:
                break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.eventSelected(chosenEvent)
        
        eventUpdaterToken?.invalidate()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return events!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let event = events![row]
        return "\(event.name) (\(event.year))"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chosenEvent = events![row]
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
