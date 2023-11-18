//
//  AppDataManager.swift
//  Authenticator
//
//  Created by PRO 14 on 13.11.23.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var onBoardState: DefaultsKey<Bool> { .init("onBoardState", defaultValue: true) }
    var passCode: DefaultsKey<String> { .init("passCode", defaultValue: "") }
    var enablePassCode: DefaultsKey<Bool> { .init("enablePassCode", defaultValue: false) }
}

struct AppDataManager {
    
    @SwiftyUserDefault(keyPath: \.onBoardState)
    static var onBoardState: Bool
    
    @SwiftyUserDefault(keyPath: \.passCode)
    static var passCode: String
    
    @SwiftyUserDefault(keyPath: \.enablePassCode)
    static var enablePassCode: Bool
    
    static var passCodeToConfirm = ""
}
