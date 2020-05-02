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
    }

}
