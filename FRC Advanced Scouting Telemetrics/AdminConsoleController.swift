//
//  AdminConsoleController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/17/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import AWSMobileClient
import AWSAppSync
import Firebase
import FirebasePerformance

/// Each object of this represents a section in the admin console and the settings that section provides
protocol AdminConsoleConfigSection {
    func sectionTitle(_ adminConsole: AdminConsoleController) -> String?
    func sectionFooter(_ adminConsole: AdminConsoleController) -> String?
    func numOfRows(_ adminConsole: AdminConsoleController) -> Int
    func tableView(_ adminConsole: AdminConsoleController, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func onSelect(_ adminConsole: AdminConsoleController, rowAt indexPath: IndexPath)
    func willSelect(_ adminConsole: AdminConsoleController, rowAt indexPath: IndexPath) -> IndexPath?
    func trailingSwipeActionsConfigiration(_ adminConsole: AdminConsoleController, forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    func registerUpdateFunction(dataChanged: @escaping (_ row: Int?) -> Void)
    func height(_ adminConsole: AdminConsoleController, tableView: UITableView, forRowAt indexPath: IndexPath) -> CGFloat
    
    typealias AdminConsoleUpdateConfigSectionHandler = (_ row: Int?) -> Void
    var reloadConfigSection: AdminConsoleUpdateConfigSectionHandler? { get set }
}

extension AdminConsoleConfigSection {
    func sectionFooter(_ adminConsole: AdminConsoleController) -> String? {
        return nil
    }
    func willSelect(_ adminConsole: AdminConsoleController, rowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    func trailingSwipeActionsConfigiration(_ adminConsole: AdminConsoleController, forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    func registerUpdateFunction(dataChanged: @escaping (_ row: Int?) -> Void) {
    }
    func height(_ adminConsole: AdminConsoleController, tableView: UITableView, forRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight
    }
}

class AdminConsoleController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var configSections = [AdminConsoleConfigSection]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configSections = [AdminConsoleScoutingTeamSection(), AdminConsoleEventsSection(), AdminConsoleInfoSection()]
        for (sectionIndex, section) in configSections.enumerated() {
            section.registerUpdateFunction {[weak self] (updatedRow) in
                DispatchQueue.main.async {
                    if let row = updatedRow {
                        self?.tableView.reloadRows(at: [IndexPath(row: row, section: sectionIndex)], with: .automatic)
                    } else {
                        self?.tableView.reloadSections([sectionIndex], with: .automatic)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        
        //Reload the table view
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return configSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configSections[section].numOfRows(self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configSections[indexPath.section].tableView(self, tableView: tableView, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return configSections[section].sectionTitle(self)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return configSections[section].sectionFooter(self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        configSections[indexPath.section].onSelect(self, rowAt: indexPath)
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        switch indexPath.section {
//        case 0:
//            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
//                return nil
//            } else {
//                let reloadAction = UITableViewRowAction.init(style: .normal, title: "Reload") {[weak self](rowAction, indexPath) in
//                    self?.reloadAt(indexPath: indexPath, inTableView: tableView)
//                }
//                reloadAction.backgroundColor = UIColor.blue
//
//                let delete = UITableViewRowAction.init(style: .destructive, title: "Delete") {[weak self](rowAction, indexPath) in
//					let confirmationAlert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to delete \(self?.trackedEvents[indexPath.row].eventName ?? "") (\(self?.trackedEvents[indexPath.row].eventKey ?? ""))", preferredStyle: .alert)
//					confirmationAlert.addAction(UIAlertAction(title: "Yes, Delete It", style: .destructive, handler: { (action) in
//						self?.deleteAt(indexPath: indexPath, inTableView: tableView)
//					}))
//					confirmationAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//
//					self?.present(confirmationAlert, animated: true, completion: nil)
//                }
//
//                let exportToCSV = UITableViewRowAction(style: .default, title: "CSV Export") {[weak self](rowAction, indexPath) in
//                    self?.exportToCSV(eventKey: self?.trackedEvents[indexPath.row].eventKey ?? "", withSourceView: nil) {_ in
//                    }
//                }
//                exportToCSV.backgroundColor = .purple
//
//                return [reloadAction, exportToCSV, delete]
//            }
//        default:
//            return nil
//        }
//    }
    
    var grayView: UIView?
    func showLoadingIndicator() {
        //Create a loading view
        let spinnerView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        grayView = UIView(frame: CGRect(x: self.tableView.frame.width / 2 - 50, y: self.tableView.frame.height / 2 - 50, width: 120, height: 120))
        grayView?.backgroundColor = UIColor.lightGray
        grayView?.backgroundColor?.withAlphaComponent(0.7)
        grayView?.layer.cornerRadius = 10
        spinnerView.frame = CGRect(x: grayView!.frame.width / 2 - 25, y: grayView!.frame.height / 2 - 25, width: 50, height: 50)
        grayView?.addSubview(spinnerView)
        spinnerView.startAnimating()
        self.tableView.addSubview(grayView!)
        
        //Prevent user interaction
        self.view.isUserInteractionEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
    }
    
    func removeLoadingIndicator() {
        //Return user interaction
        self.view.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        grayView?.removeFromSuperview()
        
        grayView = nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return configSections[indexPath.section].trailingSwipeActionsConfigiration(self, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return configSections[indexPath.section].height(self, tableView: tableView, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return configSections[indexPath.section].willSelect(self, rowAt: indexPath)
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func advancedPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Clear Local Cache?", message: "Would you like to clear the local cache of data? This will not delete any of your scouted data, simply clear out the local cache of it. This will cause longer loading times initially as data is re-downloaded and cached again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Clear Cache", style: .destructive, handler: { (action) in
            do {
                try Globals.appSyncClient?.clearCaches()
            } catch {
                CLSNSLogv("Error clearing app sync cache: \(error)", getVaList([]))
            }
            CLSNSLogv("Cleared AppSync Cache", getVaList([]))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
    }
}
