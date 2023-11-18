//
//  DispatchGroup+Extensions.swift
//  Authenticator
//
//  Created by PRO 14 on 14.11.23.
//

import Foundation
import UIKit

func main(work: @escaping () -> Void) {
    DispatchQueue.main.async {
        work()
    }
}

func main(delay: Double, work: @escaping () -> Void) {
    let deadline = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: deadline) {
        work()
    }
}

func background(qos: DispatchQoS.QoSClass = .userInitiated, work: @escaping () -> Void) {
    DispatchQueue.global(qos: qos).async {
        work()
    }
}

func animating(duration: Double = 1.0, animation: (() -> Void)?, completion: (() -> Void)? = nil) {
    UIView.animate(withDuration: duration, animations: animation ?? {}, completion: { _ in
        completion?()
    })
}
