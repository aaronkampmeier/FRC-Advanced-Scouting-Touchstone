////////////////////////////////////////////////////////////////////////////
//
// Copyright 2017 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import UIKit

/* The types of inputs cells may be */
public enum LoginViewControllerCellType: Int {
    case email
    case teamEmail
    case confirmTeamEmail
    case password
    case confirmPassword
}

public class LoginTableViewDataSource: NSObject, UITableViewDataSource {

    /** The table view managed by this data source */
    public var tableView: UITableView? {
        didSet { self.tableView?.dataSource = self }
    }

    /** Whether to configure cells with the light or dark theme */
    public var isDarkStyle = false
    
    public var serverURL: String?

    /** Username */
    public var username: String? {
        didSet { setTextFieldText(username, for: .email) }
    }
    
    public var teamEmail: String? {
        didSet {setTextFieldText(teamEmail, for: .teamEmail)}
    }
    
    public var confirmTeamEmail: String? {
        didSet { setTextFieldText(confirmTeamEmail, for: .confirmTeamEmail)}
    }

    /** Password */
    public var password: String? {
        didSet { setTextFieldText(password, for: .password) }
    }

    /** Confirm Password */
    public var confirmPassword: String? {
        didSet { setTextFieldText(confirmPassword, for: .confirmPassword) }
    }

    public var isRegistering: Bool {
        get { return _isRegistering }
        set { setRegistering(newValue, animated: false) }
    }

    /* Interaction Callbacks */
    public var didTapSubmitHandler: (() -> ())?
    public var formInputChangedHandler: (() -> ())?

    //MARK: - Private Properties -

    private var _isRegistering = false

    /* Assets */
    private let earthIcon = UIImage.earthIcon()
    private let lockIcon  = UIImage.lockIcon()
    private let mailIcon  = UIImage.mailIcon()
    private let tickIcon  = UIImage.tickIcon()

    //MARK: - Table View Data Source -

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = isRegistering ? 5 : 2
        return numberOfRows
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? LoginTableViewCell
        if cell == nil {
            cell = LoginTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
        }

        let lastCellIndex = tableView.numberOfRows(inSection: 0) - 1

        // Configure rounded caps
        cell?.topCornersRounded    = (indexPath.row == 0)
        cell?.bottomCornersRounded = (indexPath.row == lastCellIndex)

        // Configure cell content
        switch cellType(for: indexPath.row) {
        case .email:
            cell?.type = .textField
            cell?.imageView?.image = earthIcon
            cell?.textField?.placeholder = "Team Number"
            cell?.textField?.text = username
            cell?.textField?.keyboardType = .numberPad
            cell?.textChangedHandler = { self.username = cell?.textField?.text; self.formInputChangedHandler?() }
            cell?.returnButtonTappedHandler = { self.makeFirstResponder(atRow: indexPath.row + 1) }
            
        case .teamEmail:
            cell?.type = .textField
            cell?.imageView?.image = mailIcon
            cell?.textField?.placeholder = "Team Email"
            cell?.textField?.text = teamEmail
            cell?.textField?.keyboardType = .emailAddress
            cell?.textChangedHandler = { self.teamEmail = cell?.textField?.text; self.formInputChangedHandler?() }
            cell?.returnButtonTappedHandler = { self.makeFirstResponder(atRow: indexPath.row + 1) }
            
        case .confirmTeamEmail:
            cell?.type = .textField
            cell?.imageView?.image = mailIcon
            cell?.textField?.placeholder = "Confirm Email"
            cell?.textField?.text = confirmTeamEmail
            cell?.textField?.keyboardType = .emailAddress
            cell?.textChangedHandler = { self.confirmTeamEmail = cell?.textField?.text; self.formInputChangedHandler?() }
            cell?.returnButtonTappedHandler = { self.makeFirstResponder(atRow: indexPath.row + 1) }
            
        case .password:
            cell?.type = .textField
            cell?.imageView?.image = lockIcon
            cell?.textField?.placeholder = "Password"
            cell?.textField?.text = password
            cell?.textField?.isSecureTextEntry = true
            cell?.textField?.returnKeyType = isRegistering ? .next : .done
            cell?.textChangedHandler = { self.password = cell?.textField?.text; self.formInputChangedHandler?() }
            cell?.returnButtonTappedHandler = {
                if self.isRegistering { self.makeFirstResponder(atRow: indexPath.row + 1) }
                else { self.didTapSubmitHandler?() }
            }
        case .confirmPassword:
            cell?.type = .textField
            cell?.imageView?.image = lockIcon
            cell?.textField?.placeholder = "Confirm Password"
            cell?.textField?.text = confirmPassword
            cell?.textField?.isSecureTextEntry = true
            cell?.textField?.returnKeyType = .done
            cell?.textChangedHandler = { self.confirmPassword = cell?.textField?.text; self.formInputChangedHandler?() }
            cell?.returnButtonTappedHandler = { self.didTapSubmitHandler?() }
        }

        // Apply the theme after all cell configuration is done
        applyTheme(to: cell!)

        return cell!
    }

    func applyTheme(to tableViewCell: LoginTableViewCell) {
        tableViewCell.imageView?.tintColor = UIColor(white: isDarkStyle ? 0.4 : 0.6, alpha: 1.0)
        tableViewCell.textLabel?.textColor = isDarkStyle ? .white : .black

        // Only touch the text field if we're actively using it
        if tableViewCell.textChangedHandler != nil {
            tableViewCell.textField?.textColor = isDarkStyle ? .white : .black
            tableViewCell.textField?.keyboardAppearance = isDarkStyle ? .dark : .default

            if isDarkStyle {
                let placeholderText = tableViewCell.textField?.placeholder
                let placeholderTextColor = UIColor(white: 0.45, alpha: 1.0)
                #if swift(>=4.0)
                let attributes = [NSAttributedString.Key.foregroundColor: placeholderTextColor]
                #else
                    let attributes = [NSForegroundColorAttributeName: placeholderTextColor]
                #endif

                tableViewCell.textField?.attributedPlaceholder = NSAttributedString(string: placeholderText!, attributes: attributes)
            }
            else {
                let placeholderText = tableViewCell.textField?.placeholder
                tableViewCell.textField?.attributedPlaceholder = nil //setting this as nil also sets `placeholder` to nil
                tableViewCell.textField?.placeholder = placeholderText
            }
        }
    }

    private func cellType(for rowIndex: Int) -> LoginViewControllerCellType {
        if isRegistering {
            switch rowIndex {
            case 0:
                return .email
            case 1:
                return .teamEmail
            case 2:
                return .confirmTeamEmail
            case 3:
                return .password
            case 4:
                return .confirmPassword
            default:
                assertionFailure()
                return .email
            }
        } else {
            switch rowIndex {
            case 0:
                return .email
            case 1:
                return .password
            default:
                assertionFailure()
                return .email
            }
        }

    }

    private func tableIndexPath(for cellType: LoginViewControllerCellType) -> IndexPath? {
        var rowIndex = 0
        
        if isRegistering {
            switch cellType {
            case .email:
                rowIndex = 0
            case .teamEmail:
                rowIndex = 1
            case .confirmTeamEmail:
                rowIndex = 2
            case .password:
                rowIndex = 3
            case .confirmPassword:
                rowIndex = 4
            }
        } else {
            switch cellType {
            case .email:
                rowIndex = 0
            case .password:
                rowIndex = 1
            default:
                rowIndex = -1
            }
        }

        guard rowIndex >= 0 else { return nil }
        return IndexPath(row: rowIndex, section: 0)
    }

    private func setTextFieldText(_ text: String?, for cellType: LoginViewControllerCellType) {
        guard let text = text else { return }
        guard let indexPath = tableIndexPath(for: cellType) else { return }
        guard let cell = tableView?.cellForRow(at: indexPath) as? LoginTableViewCell else { return }
        cell.textField?.text = text
    }

    private func setSwitchValue(_ on: Bool, for cellType: LoginViewControllerCellType) {
        guard let indexPath = tableIndexPath(for: cellType) else { return }
        guard let cell = tableView?.cellForRow(at: indexPath) as? LoginTableViewCell else { return }
        cell.switch?.isOn = on
    }

    // MARK: - Login/Register Transition

    func setRegistering(_ isRegistering: Bool, animated: Bool) {
        guard _isRegistering != isRegistering else {
            return
        }

        _isRegistering = isRegistering
        
        tableView?.beginUpdates()
        
        //Insert / Delete the 'team email' field
        let teamEmailIndex = 1
        if _isRegistering {
            tableView?.insertRows(at: [IndexPath(row: teamEmailIndex, section: 0)], with: animated ? .fade : .none)
        } else {
            tableView?.deleteRows(at: [IndexPath(row: teamEmailIndex, section: 0)], with: animated ? .fade : .none)
        }
        
        let confirmTeamEmailIndex = 2
        if _isRegistering {
            tableView?.insertRows(at: [IndexPath(row: confirmTeamEmailIndex, section: 0)], with: animated ? .fade : .none)
        } else {
            tableView?.deleteRows(at: [IndexPath(row: confirmTeamEmailIndex, section: 0)], with: animated ? .fade : .none)
        }
        
        let rowIndex = 4
        
        // Insert/Delete the 'confirm password' field
        if _isRegistering {
            tableView?.insertRows(at: [IndexPath(row: rowIndex, section: 0)], with: animated ? .fade : .none)
        }
        else {
            tableView?.deleteRows(at: [IndexPath(row: rowIndex, section: 0)], with: animated ? .fade : .none)
        }
        
        tableView?.endUpdates()
    }

    // MARK: - Keyboard Handling
    func makeFirstResponder(atRow row: Int) {
        let cell = tableView?.cellForRow(at: IndexPath(row: row, section: 0)) as! LoginTableViewCell
        cell.textField?.becomeFirstResponder()
    }
}
