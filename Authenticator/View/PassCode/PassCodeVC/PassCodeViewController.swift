//
//  PassCodeViewController.swift
//  Authenticator
//
//  Created by PRO 14 on 18.11.23.
//

import UIKit
import FloatingPanel

enum PassState {
    case create
    case confirm
    case enter
}

class PassCodeViewController: UIViewController {

    @IBOutlet weak var code4Label: UILabel!
    @IBOutlet weak var code4Container: UIView!
    @IBOutlet weak var code3Label: UILabel!
    @IBOutlet weak var code3Container: UIView!
    @IBOutlet weak var code2Label: UILabel!
    @IBOutlet weak var code2Container: UIView!
    @IBOutlet weak var code1Label: UILabel!
    @IBOutlet weak var code1Container: UIView!
    @IBOutlet weak var hiddenTextField: UITextField!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topStackView: UIStackView!
    
    var labels: [UILabel] = []
    var passState: PassState = .create
    
    var pointerPos: Int {
        let counter = (self.code1Label.text.isNilOrEmpty ? 0:1)
                    + (self.code2Label.text.isNilOrEmpty ? 0:1)
                    + (self.code3Label.text.isNilOrEmpty ? 0:1)
                    + (self.code4Label.text.isNilOrEmpty ? 0:1)
        return counter
    }
    
    var invalidCode = false {
        didSet {
            self.invalidCode ? self.showInvalidAlert() : self.hideInvalidAlert()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        self.hiddenTextField.delegate = self
        labels = [code1Label, code2Label, code3Label, code4Label]
    }
    
    @objc func textFieldChanged() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.hiddenTextField.becomeFirstResponder()
    }
    
    private func configureItems() {
        switch self.passState {
        case .create:
            self.topStackView.isHidden = false
            self.titleLabel.text = "Create Your Passcode"
            self.subTitleLabel.text = "Please set a numeric passcode. It should consist of at least 4 digits for security"
        case .confirm:
            self.topStackView.isHidden = false
            self.titleLabel.text = "Confirm Your Passcode"
            self.subTitleLabel.text = "To ensure accuracy, please re-enter your passcode."
            
        case .enter:
            self.topStackView.isHidden = true
            self.titleLabel.text = "Enter Your Password"
            self.subTitleLabel.text = "Please enter your password to access your account."
        }
    }

    @IBAction func backAction(_ sender: Any) {
        switch self.passState {
        case .create:
            self.navigationController?.popViewController(animated: true)
            AppDataManager.passCodeToConfirm = ""
        case .confirm:
            self.navigationController?.popViewController(animated: true)
        case .enter:
            print("Shouldn't happen this shit")
        }
    }
    
    private func showInvalidAlert() {
        self.code1Container.viewBorderWidth = 1
        self.code2Container.viewBorderWidth = 1
        self.code3Container.viewBorderWidth = 1
        self.code4Container.viewBorderWidth = 1
        
        self.code1Container.layer.borderColor = UIColor.red.cgColor
        self.code2Container.layer.borderColor = UIColor.red.cgColor
        self.code3Container.layer.borderColor = UIColor.red.cgColor
        self.code4Container.layer.borderColor = UIColor.red.cgColor
        
    }
    
    private func hideInvalidAlert() {
        self.code1Container.viewBorderWidth = 0
        self.code2Container.viewBorderWidth = 0
        self.code3Container.viewBorderWidth = 0
        self.code4Container.viewBorderWidth = 0
    }

}

extension PassCodeViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let pos = self.pointerPos
        if string.count > 1 {
            if string.count == 4 {
                for i in 0..<string.count {
                    self.labels[i].text = string[i]
                }
                self.changeState()
                return true
            }
            return false
        }
        switch string {
        case "0"..."9":
            if pos >= 0 && pos <= 3 {
                labels[pos].text = string
            }
        case "":
            if pos > 0  && pos <= 4 {
                labels[pos - 1].text = ""
            }
        default:
            print("ERR")
            return false
        }
        
        if self.pointerPos == 4 {
            self.changeState()
        }
        return true
    }
    
    private func changeState() {
        var text = ""
        labels.forEach { label in
            text += label.text ?? ""
        }
        guard text.count == 4 else {
            print("ERRRRR")
            return
        }
        
        switch self.passState {
        case .create:
            AppDataManager.passCodeToConfirm = text
            let vc = PassCodeViewController()
            vc.passState = .confirm
            self.navigationController?.pushViewController(vc, animated: true)
        case .confirm:
            self.invalidCode = text != AppDataManager.passCodeToConfirm
            
            print("Entered: ", AppDataManager.passCodeToConfirm)
            print("ToConfirm: ", text )
            if text == AppDataManager.passCodeToConfirm {
                AppDataManager.passCode = text
                self.navigationController?.popToRootViewController(animated: true)
                AppDataManager.passCodeToConfirm = ""
            }
        case .enter:
            self.invalidCode = text != AppDataManager.passCode
            if text == AppDataManager.passCode, !text.isEmpty {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
