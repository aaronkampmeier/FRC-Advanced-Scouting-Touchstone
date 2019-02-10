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
    
    @IBOutlet weak var introText: UILabel!
    var delegate: EventSelection?
    fileprivate var events: [(eventKey: String, eventName: String)] = []
    fileprivate var currentEvent: String?
    fileprivate var chosenEvent: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        eventPicker.dataSource = self
        eventPicker.delegate = self
        
        //Load all the events
        Globals.appDelegate.appSyncClient?.fetch(query: ListTrackedEventsQuery(), cachePolicy: .returnCacheDataAndFetch) {[weak self] result, error in
            if Globals.handleAppSyncErrors(forQuery: "ListTrackedEventsQuery", result: result, error: error) {
                self?.events = result?.data?.listTrackedEvents?.map {(eventKey: $0!.eventKey, eventName: $0!.eventName)} ?? []
                self?.load()
            } else {
                //TODO: Show error
            }
        }
    }
    
    fileprivate func load() {
        if events.count == 0 {
            introText.isHidden = false
        } else {
            introText.isHidden = true
        }
        
        currentEvent = delegate?.currentEventKey()
        
        self.chosenEvent = currentEvent
        
        eventPicker.reloadAllComponents()
        
        if let current = currentEvent {
            if let index = events.firstIndex(where: {$0.eventKey == current}) {
                eventPicker.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO: Real time update
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
        return events.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let event = events[row]
        return "\(event.eventName) (\(event.eventKey.trimmingCharacters(in: CharacterSet.letters)))"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (events.count ?? 0) > 0 {
            chosenEvent = events[row].eventKey
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
    func eventSelected(_ eventKey: String?)
    func currentEventKey() -> String?
}
