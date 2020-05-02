//
//  Setting.swift
//  webrtc-heartbeat
//
//  Created by yorifuji on 2020/05/02.
//  Copyright © 2020 yorifuji. All rights reserved.
//

import Foundation

class Setting {
    static let shared = Setting()

    private var params: [String:Any]

    private init() {
        params = UserDefaults.standard.dictionary(forKey: "Setting") ?? [:]
        if params.isEmpty {
            // set default params
            params["room"] = "room1"
            params["name"] = "you"
        }
    }

    private func save(key: String, val: String) {
        params[key] = val
        UserDefaults.standard.set(params, forKey: "Setting")
    }

    var room: String {
        get { return params["room"] as! String }
        set { save(key: "room", val: newValue) }
    }

    var name: String {
        get { return params["name"] as! String }
        set { save(key: "name", val: newValue) }
    }
}
