//
//  UserManagementViewModel.swift
//  IAR-SDK-Sample
//
//  Created by Rogerio on 2022-01-13.
//

import Foundation
import IAR_Core_SDK

public struct UserMenuItem {
    public let ID: UserMenuItemID
    public let Icon: String
    public let Title: String
}

public enum UserMenuItemID {
    case userIDLabel
    case userID
    case createUser
    case login
    case logout
    case migrateUser
}

public struct UserManagementViewModel {
    
    public let userController = ExternalUsersController.shared
    
    public var isLoggedIn: Bool {
        !userController.isGuest
    }
    
    public var userID: String? {
        userController.userId
    }
    
    private let login = UserMenuItem(ID: .login, Icon: "lock.open.display", Title: "Login")
    private let logout = UserMenuItem(ID: .logout, Icon: "power", Title: "Logout")
    
    public var menuItems: [UserMenuItem] {
        [
            UserMenuItem(ID: .userIDLabel, Icon: "person", Title: "User ID:"),
            UserMenuItem(ID: .userID, Icon: "", Title: self.userID ?? "---"),
            UserMenuItem(ID: .createUser, Icon: "person.fill.badge.plus", Title: "Create New User"),
            (isLoggedIn ? logout : login),
            UserMenuItem(ID: .migrateUser, Icon: "lock.rectangle.stack", Title: "Migrate User"),
        ]
    }
    
}
