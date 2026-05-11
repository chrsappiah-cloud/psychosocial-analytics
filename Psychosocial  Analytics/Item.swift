//
//  Item.swift
//  Psychosocial  Analytics
//
//  Created by Christopher Appiah-Thompson  on 12/5/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
