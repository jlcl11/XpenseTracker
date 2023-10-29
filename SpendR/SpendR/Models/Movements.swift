//
//  Movements.swift
//  SpendR
//
//  Created by José Luis Corral López on 5/9/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Movement {
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
}

struct MovementProperties: Codable {
    let owner: String?
    let description: String?
    let amount: Double?
    let date: Date?
    let isIncome: Bool?
    let tags: [TagProperties]?
}
