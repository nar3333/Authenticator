//
//  SettingsModel.swift
//  Authenticator
//
//  Created by PRO 14 on 15.11.23.
//

import Foundation

struct SettingsModel {
    let imageName: String
    let title: String
}

let SETTINGSITEMS: [SettingsModel] = [
    .init(imageName: "lock", title: "Autolock"),
    .init(imageName: "key", title: "Change password"),
    
    .init(imageName: "message_question", title: "Help"),
    .init(imageName: "book", title: "Terms of use"),
    .init(imageName: "security_user", title: "Privacy Policy"),
    .init(imageName: "share", title: "Share the App"),
    .init(imageName: "like", title: "Rate the app"),
    
]
