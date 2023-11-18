//
//  OnBoardModel.swift
//  Authenticator
//
//  Created by PRO 14 on 14.11.23.
//

import Foundation

struct OnBoardModel {
    let imageName: String
    let title: String
    let subtitle: String?
    let secondaryTitle: String
    let buttonTitle: String
}

let ONBOARDITEMS: [OnBoardModel] = [
    
    .init(imageName: "onboard1", title: "We're here to enhance the security of your online accounts and protect your personal information.", subtitle: nil, secondaryTitle: "Best 2FA Authenticator app", buttonTitle: "Let's get started!"),
    .init(imageName: "onboard2", title: "We value your feedback", subtitle: "We love when you write reviews - they motivate us to work on the app even more!", secondaryTitle: "Best 2FA Authenticator app", buttonTitle: "Continue"),
    .init(imageName: "onboard3", title: "Tap \("Add Account") to start the setup process.", subtitle: nil, secondaryTitle: "Best 2FA Authenticator app", buttonTitle: "Continue"),
    .init(imageName: "onboard4", title: "Ensure the safety of your device with a password", subtitle: nil, secondaryTitle: "Best 2FA Authenticator app", buttonTitle: "Continue"),
    .init(imageName: "onboard5", title: "We're committed to keeping your online accounts secure.", subtitle: "Protect your accounts from unauthorized access First 3 days free, then $4,99/week", secondaryTitle: "Or proceed with limited version", buttonTitle: "Try Free & Subscribe"),
]
