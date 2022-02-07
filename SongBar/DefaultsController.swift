//
//  DefaultsController.swift
//  SongBar
//
//  Created by Justin Oakes on 2/7/22.
//  Copyright © 2022 corpe. All rights reserved.
//

import Foundation
import Combine

class DefaultsController {
    
    static let shared = DefaultsController()
    private let userDefault = UserDefaults.standard

    // This will be handled by IAP or registration check in the future
    @Published var isPremium: Bool = true
    
    
}
