//
//  CameraPermissionAlertViewController.swift
//  Authenticator
//
//  Created by PRO 14 on 18.11.23.
//

import UIKit

enum CameraPermissionAlertAction {
    case cancel
    case openSettings
}

class CameraPermissionAlertViewController: UIViewController {
    @IBOutlet weak var backgroundTapView: UIView!
    @IBOutlet weak var openSettingsButton: UIButton!
    
    @IBOutlet weak var contentContainer: UIView!
    
    var onClose: (_ action: CameraPermissionAlertAction) -> Void = {_ in}
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.close))
        backgroundTapView.addGestureRecognizer(tap)
    }
    
    @objc func close() {
        dismiss(animated: true)
        onClose(.cancel)
    }
    
    @IBAction func openSettingsAction(_ sender: Any) {
        self.dismiss(animated: true)
        onClose(.openSettings)
    }

}
