//
//  Tag.swift
//  SpendR
//
//  Created by José Luis Corral López on 5/9/23.
//

import Foundation
import UIKit

struct Tag: Hashable {
    var properties: TagProperties?
    var icon: UIImage?
    var color: UIColor?
    
    func hash(into hasher: inout Hasher) {
        if let name = properties?.name {
            hasher.combine(name)
        }
    }
    
    static func ==(lhs: Tag, rhs: Tag) -> Bool {
        return lhs.properties == rhs.properties
    }
  
    init(properties: TagProperties? = nil) {
        self.properties = properties
        self.icon = UIImage(systemName: properties?.iconName ?? "")
        self.color = UIColor(rgb: properties?.color ?? 0)
    }
}

struct TagProperties: Codable, Equatable {
    var iconName: String?
    var color: Int?
    var name: String?
    var owner: String?
    
    init(iconName: String? = nil, color: Int? = nil, name: String? = nil, owner: String? = nil) {
        self.iconName = iconName
        self.color = color
        self.name = name
        self.owner = owner
    }

    static func ==(lhs: TagProperties, rhs: TagProperties) -> Bool {
        return lhs.iconName == rhs.iconName &&
               lhs.color == rhs.color &&
               lhs.name == rhs.name &&
               lhs.owner == rhs.owner
    }
}

