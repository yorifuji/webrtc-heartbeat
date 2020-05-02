//
//  SettingViewController.swift
//  webrtc-heartbeat
//
//  Created by yorifuji on 2020/05/02.
//  Copyright © 2020 yorifuji. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        switch indexPath.section {
            case 0:
                if indexPath.row == 0 {
                    // room
                    cell.detailTextLabel?.text = Setting.shared.room
                }
                else if indexPath.row == 1 {
                    // name
                    cell.detailTextLabel?.text = Setting.shared.name
                }
            case 1:
                break
            default:
                break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                inputRoom()
            }
            else if indexPath.row == 1 {
                inputName()
            }
        }
    }

}

extension SettingViewController {
    func inputRoom() {
        let alert = UIAlertController(title: "room", message: "please input room id", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { action in
            guard let textFields = alert.textFields else {
                return
            }
            guard !textFields.isEmpty else {
                return
            }
            if let text: String = textFields[0].text {
                Setting.shared.room = text
                self.tableView.reloadData()
            }
        }
        alert.addTextField { (field:UITextField) in
            field.text = Setting.shared.room
        }
        alert.addAction(ok)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }

    func inputName() {
        let alert = UIAlertController(title: "name", message: "please input your name", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { action in
            guard let textFields = alert.textFields else {
                return
            }
            guard !textFields.isEmpty else {
                return
            }
            if let text: String = textFields[0].text {
                Setting.shared.name = text
                self.tableView.reloadData()
            }
        }
        alert.addTextField { (field:UITextField) in
            field.text = Setting.shared.name
        }
        alert.addAction(ok)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }

}
