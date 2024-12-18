//
//  Item.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-18.
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
