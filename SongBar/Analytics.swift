//
//  Analytics.swift
//  SongBar
//
//  Created by Justin Oakes on 4/12/22.
//  Copyright © 2022 joakes. All rights reserved.
//

import Foundation
import Firebase

enum Event: String {
    case launchDirectDownload
    case launchMAS
    case toggleTrackInfo
    case toggleControlls
    case launchWeb
    case registerApp
}

extension Analytics {
    static func logEvent(event: Event, parameters: [String: Any]?) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }
}
