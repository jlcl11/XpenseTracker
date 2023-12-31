//
//  User.swift
//  SpendR
//
//  Created by José Luis Corral López on 5/9/23.
//

import Foundation

struct User {
    var properties: UserProperties
    var userTags: [Tag]
    var movements: [Movement]
}

struct UserProperties: Codable {
    let name: String?
    let surname: String?
    let email: String?
    var userTags: [TagProperties]?
    var currency: String
    var currencyName: String
    var balance: Double?
}

