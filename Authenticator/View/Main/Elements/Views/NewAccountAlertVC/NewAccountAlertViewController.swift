//
//  NewAccountAlertViewController.swift
//  Authenticator
//
//  Created by PRO 14 on 18.11.23.
//

import UIKit

enum NewAccAlertAction {
    case cancel
    case qrScan
    case enterKey
    case gallery
}

class NewAccountAlertViewController: UIViewController {
    @IBOutlet weak var grabberView: UIView!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var backgroundTapView: UIView!
    @IBOutlet weak var qrScanButton: UIButton!
    
    @IBOutlet weak var enterKeyButton: UIButton!
    @IBOutlet weak var downloadFromGalleryButton: UIButton!
    
    var onClose: (_ action: NewAccAlertAction) -> Void = {_ in}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.close))
        backgroundTapView.addGestureRecognizer(tap)
    }
    
    @objc func close() {
        dismiss(animated: true)
        onClose(.cancel)
    }

    @IBAction func enterKeyAction(_ sender: Any) {
        dismiss(animated: true)
        onClose(.enterKey)
    }
    @IBAction func qrScanAction(_ sender: Any) {
        dismiss(animated: true)
        onClose(.qrScan)
    }
    
    @IBAction func downloadFromGalleryAction(_ sender: Any) {
        dismiss(animated: true)
        onClose(.gallery)
    }
}
