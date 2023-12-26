//
//  UserManager.swift
//  SpendR
//
//  Created by José Luis Corral on 10/11/23.
//

import Foundation

class UserManager {
    static let shared = UserManager()

    private var currentUser: User?

    private init() {}

    func getCurrentUser() -> User? {
        return currentUser
    }

    func setCurrentUser(_ user: User) {
        currentUser = user
    }
}

