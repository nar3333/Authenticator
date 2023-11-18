//
//  TokenEntity.swift
//  Authenticator
//
//  Created by PRO 14 on 16.11.23.
//

import Foundation
import OneTimePassword
import Base32

private let defaultTimerFactor = Generator.Factor.timer(period: 30)
private let defaultCounterFactor = Generator.Factor.counter(0)

enum TokenType {
    case counter, timer
}

enum DigitCount: Int {
    case six   = 6
    case seven = 7
    case eight = 8
}

struct TokenEntity {
    enum Effect {
        case saveNewToken(Token)
        case showErrorMessage(String)
    }
    
    var accountName: String = ""
    var serviceName: String = ""
    var secret: String = ""
    var tokenType: TokenType = .timer
    var digitCount: DigitCount = .six
    var algorithm: Generator.Algorithm = .sha1

    private var isValid: Bool {
        return !secret.isEmpty && !(accountName.isEmpty && serviceName.isEmpty)
    }
}

extension TokenEntity {
    mutating func submit() -> Effect {
        guard isValid else {
            return .showErrorMessage("A secret and some identifier are required.")
        }

        guard let secretData = MF_Base32Codec.data(fromBase32String: secret),
            !secretData.isEmpty else {
                return .showErrorMessage("The secret key is invalid.")
        }

        let factor: Generator.Factor
        switch tokenType {
        case .counter:
            factor = defaultCounterFactor
        case .timer:
            factor = defaultTimerFactor
        }

        guard let generator = Generator(
            factor: factor,
            secret: secretData,
            algorithm: algorithm,
            digits: digitCount.rawValue
            ) else {
                // This UI doesn't allow the user to create an invalid period or digit count,
                // so a generic error message is acceptable here.
                return .showErrorMessage("Invalid Token")
        }

        let token = Token(
            name: serviceName,
            issuer: accountName,
            generator: generator
        )

        return .saveNewToken(token)
    }
}
