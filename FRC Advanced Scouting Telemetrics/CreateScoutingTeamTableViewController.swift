//
//  CreateScoutingTeamTableViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/6/20.
//  Copyright © 2020 Kampfire Technologies. All rights reserved.
//

import UIKit

class CreateScoutingTeamTableViewController: UITableViewController {
    
    var enteredTeamName: String?
    var enteredTeamNumber: Int?
    var leadName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        navigationItem.title = "Create Scouting Team"
        navigationItem.prompt = "Create a new scouting team using a custom name and associating it with your FRC team."
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createNewTeam))
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.systemGreen]
            navigationItem.standardAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func createNewTeam() {
        if let name = enteredTeamName, let number = enteredTeamNumber, let leadName = leadName {
            let activityIndicator = UIActivityIndicatorView()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
            activityIndicator.startAnimating()
            Globals.appSyncClient?.perform(mutation: CreateScoutingTeamMutation(name: name, associatedFrcTeamNumber: number, leadName: leadName), resultHandler: {[weak self] (result, error) in
                activityIndicator.stopAnimating()
                self?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(self?.createNewTeam))
                
                if Globals.handleAppSyncErrors(forQuery: "CreateScoutingTeamMutation", result: result, error: error) {
                    let _ = Globals.appSyncClient?.store?.withinReadWriteTransaction({ (transaction) -> Bool in
                        try? transaction.update(query: ListEnrolledScoutingTeamsQuery()) { (selectionSet) in
                            if let snapshot = result?.data?.createScoutingTeam?.snapshot {
                                selectionSet.listEnrolledScoutingTeams?.append(ListEnrolledScoutingTeamsQuery.Data.ListEnrolledScoutingTeam(snapshot: snapshot))
                            }
                            return
                        }
                        return true
                    })
                    
                    self?.dismiss(animated: true, completion: nil)
                }
            })
        } else {
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter valid entries before creating the team.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CreateScoutingTeamTableViewCell

        switch indexPath.row {
        case 0:
            cell.label.text = "Scouting Team Name:"
            cell.textField.placeholder = "The Scouts"
            cell.registerTextFieldHandler { (newText) in
                //Validation check
                if let text = newText {
                    self.enteredTeamName = text
                    return true
                } else {
                    self.enteredTeamName = nil
                    return false
                }
            }
        case 1:
            cell.label.text = "Your FRC Team Number:"
            cell.textField.placeholder = "4256"
            cell.registerTextFieldHandler { (newText) -> Bool in
                if let text = newText, let newNumber = Int(text) {
                    if newNumber > 0 && newNumber < 99999 {
                        self.enteredTeamNumber = newNumber
                        return true
                    } else {
                        return false
                    }
                } else {
                    self.enteredTeamNumber = nil
                    return false
                }
            }
        case 2:
            cell.label.text = "Your Name:"
            cell.textField.placeholder = "Johnny Appleseed"
            cell.registerTextFieldHandler { (newText) -> Bool in
                self.leadName = newText
                return newText != nil
            }
        default:
            break
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
