//
//  SecondaryPaywallViewController.swift
//  Authenticator
//
//  Created by PRO 14 on 18.11.23.
//

import UIKit

class SecondaryPaywallViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var subscribeButton: UIButton!
    
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func termsAction(_ sender: Any) {
    }
    
    @IBAction func restoreAction(_ sender: Any) {
        SubscriptionWrapper.shared.restore { [weak self] completed in
            guard let self else { return }
            if !completed {
                self.showAlert(title: "Something went wrong..", message: "Please, try later!")
            } else {
                self.showAlert(message: "Restore Complete")
            }
        }
    }
    @IBAction func privacyAction(_ sender: Any) {
    }
    @IBAction func subscribeAction(_ sender: Any) {
        self.makePurchase()
    }
    
    private func makePurchase() {
        let product = SubscriptionWrapper.shared.apphudProduct(for: .week)
        SubscriptionWrapper.shared.purchase(product!) { activated in
            print("Showed")
            if activated {
                main {
                    self.dismiss(animated: true)
                }
            } else {
                print("Canceled or something went wrong")
            }
        }
    }

}
