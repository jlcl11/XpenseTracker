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
    
    // Hashable conformidad personalizada para Tag
    func hash(into hasher: inout Hasher) {
        // Use una propiedad única o combinación de propiedades que garantice la unicidad
        if let name = properties?.name {
            hasher.combine(name)
        }
    }
    
    // Implementa Equatable si deseas comparar Tags
    static func ==(lhs: Tag, rhs: Tag) -> Bool {
        // Compara las propiedades que definas como relevantes para la igualdad
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

    // Implementación personalizada de Equatable para comparar instancias de TagProperties
    static func ==(lhs: TagProperties, rhs: TagProperties) -> Bool {
        // Compara las propiedades relevantes para la igualdad
        return lhs.iconName == rhs.iconName &&
               lhs.color == rhs.color &&
               lhs.name == rhs.name &&
               lhs.owner == rhs.owner
    }
}

