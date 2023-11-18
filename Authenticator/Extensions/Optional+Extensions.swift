//
//  Optional+Extensions.swift
//  Authenticator
//
//  Created by PRO 14 on 18.11.23.
//

import Foundation

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        self == nil || self == ""
    }
}
