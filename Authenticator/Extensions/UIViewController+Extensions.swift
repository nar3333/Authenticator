//
//  UIViewController+Extensions.swift
//  Authenticator
//
//  Created by PRO 14 on 16.11.23.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String? = nil, message: String? = nil, actions: [UIAlertAction]? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        
        if let actions {
            actions.forEach { action in
                alertVC.addAction(action)
            }
        }
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true)
    }
}
