//
//  Movements.swift
//  SpendR
//
//  Created by José Luis Corral López on 5/9/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Movement: Equatable {
    let properties: MovementProperties
    let tags: [Tag]

    init(properties: MovementProperties) {
        self.properties = properties

        var movementTags: [Tag] = []
        if let tagPropertiesArray = properties.tags {
            for tagProperties in tagPropertiesArray {
                movementTags.append(Tag(properties: tagProperties))
            }
        }
        self.tags = movementTags
    }

    static func ==(lhs: Movement, rhs: Movement) -> Bool {
        // Compara las propiedades y las etiquetas para determinar la igualdad
        return lhs.properties == rhs.properties && lhs.tags == rhs.tags
    }
}

struct MovementProperties: Codable {
    let name:String?
    let description: String?
    let amount: Double?
    let date: Date?
    let isIncome: Bool?
    let tags: [TagProperties]?
}
