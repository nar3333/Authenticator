//
//  Date+Extensions.swift
//  Authenticator
//
//  Created by PRO 14 on 17.11.23.
//

import Foundation

extension Date {
    func seconds() -> Int {
        let calendar = Calendar.current
        let component = calendar.component(.second, from: self)
        return component
    }
}
