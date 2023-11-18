//
//  NewAccountViewController.swift
//  Authenticator
//
//  Created by PRO 14 on 16.11.23.
//

import UIKit
import OneTimePassword
import IQKeyboardManagerSwift

class NewAccountViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mainStackContainer: UIStackView!
    
    @IBOutlet weak var sha512Label: UILabel!
    @IBOutlet weak var sha512View: UIView!
    @IBOutlet weak var sha256Label: UILabel!
    @IBOutlet weak var sha256View: UIView!
    @IBOutlet weak var sha1Label: UILabel!
    @IBOutlet weak var sha1View: UIView!
    
    @IBOutlet weak var eightDigitsLabel: UILabel!
    @IBOutlet weak var eightDigitsView: UIView!
    @IBOutlet weak var sevenDigitsLabel: UILabel!
    @IBOutlet weak var sevenDigitsView: UIView!
    @IBOutlet weak var sixDigitsLabel: UILabel!
    @IBOutlet weak var sixDigitsView: UIView!
    
    @IBOutlet weak var counterBasedLabel: UILabel!
    @IBOutlet weak var counterBasedView: UIView!
    @IBOutlet weak var timeBasedLabel: UILabel!
    @IBOutlet weak var timeBasedView: UIView!
    
    @IBOutlet weak var addArrowImageView: UIImageView!
    @IBOutlet weak var additionalPanelView: UIStackView!
    @IBOutlet weak var secretKeyTextField: UITextField!
    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var serviceNameTextField: UITextField!
    
    @IBOutlet weak var additionalStackView: UIStackView!
    @IBOutlet weak var doneButton: UIButton!
    
    var additionalShown = false {
        didSet {
            self.updateAdditional()
        }
    }
    
    var tokenEntity: TokenEntity = TokenEntity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        self.setupAdditional()
        self.keyboardManagerConfigs()
        self.configureTextFields()
    }
    
    //MARK: - IQKeyboardManager Configurations
    private func keyboardManagerConfigs() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysShow
        IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses.append(UIStackView.self)
        IQKeyboardManager.shared.toolbarManageBehaviour = .bySubviews
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        let effect = self.tokenEntity.submit()
        dump(tokenEntity)
        switch effect {
        case .saveNewToken(let token):
            let store = OTPManager.shared.getStore()
            do {
                try store.addToken(token)
                self.navigationController?.popViewController(animated: true)
            } catch {
                self.showAlert(message: "Please, try later!")
            }
        case .showErrorMessage(let message):
            self.showAlert(message: message)
        }
    }
}

//MARK: - Setup Components
extension NewAccountViewController {
    
    private func configureTextFields() {
        self.serviceNameTextField.addTarget(self, action: #selector(fieldChanged(_:)), for: .editingChanged)
        self.accountNameTextField.addTarget(self, action: #selector(fieldChanged(_:)), for: .editingChanged)
        self.secretKeyTextField.addTarget(self, action: #selector(fieldChanged(_:)), for: .editingChanged)
    }
    
    @objc func fieldChanged(_ textField: UITextField) {
        switch textField {
        case self.serviceNameTextField:
            self.tokenEntity.accountName = textField.text ?? ""
        case self.accountNameTextField:
            self.tokenEntity.serviceName = textField.text ?? ""
        case self.secretKeyTextField:
            self.tokenEntity.secret = textField.text ?? ""
        default:
            print("Something strange")
        }
    }
    
    
    //MARK: - Additional options Setup
    private func setupAdditional() {
        let additTapGesture = UITapGestureRecognizer(target: self, action: #selector(additionalTapped))
        self.additionalPanelView.addGestureRecognizer(additTapGesture)
        self.updateAdditional()
        
        self.setupFactors()
        self.setupDigitsCount()
        self.setupAlgorithm()
    }
    
    @objc func additionalTapped() {
        self.additionalShown.toggle()
    }
    
    private func updateAdditional() {
        self.additionalStackView.isHidden = !self.additionalShown
        let imageName = self.additionalShown ? "arrow_up":"arrow_down"
        self.addArrowImageView.image = UIImage(named: imageName)
    }
    
    //MARK: - Additional options - Factor
    private func setupFactors() {
        self.selectedFactor(self.tokenEntity.tokenType)
        
        let timeBasedTapGesture = UITapGestureRecognizer(target: self, action: #selector(timeBasedTapped))
        self.timeBasedView.addGestureRecognizer(timeBasedTapGesture)
        
        let counterBasedTapGesture = UITapGestureRecognizer(target: self, action: #selector(counterBasedTapped))
        self.counterBasedView.addGestureRecognizer(counterBasedTapGesture)
    }
    
    @objc func timeBasedTapped() {
        self.selectedFactor(.timer)
        self.tokenEntity.tokenType = .timer
    }
    
    @objc func counterBasedTapped() {
        self.selectedFactor(.counter)
        self.tokenEntity.tokenType = .counter
    }
    
    //MARK: - Additional options - Digits Count
    private func setupDigitsCount() {
        self.selectDigitsCount(self.tokenEntity.digitCount)
        
        let sixTapGesture = UITapGestureRecognizer(target: self, action: #selector(sixTapped))
        self.sixDigitsView.addGestureRecognizer(sixTapGesture)
        
        let sevenTapGesture = UITapGestureRecognizer(target: self, action: #selector(sevenTapped))
        self.sevenDigitsView.addGestureRecognizer(sevenTapGesture)
        
        let eightTapGesture = UITapGestureRecognizer(target: self, action: #selector(eightTapped))
        self.eightDigitsView.addGestureRecognizer(eightTapGesture)
        
    }
    
    @objc func sixTapped() {
        self.selectDigitsCount(.six)
        self.tokenEntity.digitCount = .six
    }
    
    @objc func sevenTapped() {
        self.selectDigitsCount(.seven)
        self.tokenEntity.digitCount = .seven
    }
    
    @objc func eightTapped() {
        self.selectDigitsCount(.eight)
        self.tokenEntity.digitCount = .eight
    }
    
    //MARK: - Additional options - Algorithm
    private func setupAlgorithm() {
        self.selectAlgorithm(self.tokenEntity.algorithm)
        
        let sha1TapGesture = UITapGestureRecognizer(target: self, action: #selector(sha1Tapped))
        self.sha1View.addGestureRecognizer(sha1TapGesture)
        
        let sha256TapGesture = UITapGestureRecognizer(target: self, action: #selector(sha256Tapped))
        self.sha256View.addGestureRecognizer(sha256TapGesture)
        
        let sha512TapGesture = UITapGestureRecognizer(target: self, action: #selector(sha512Tapped))
        self.sha512View.addGestureRecognizer(sha512TapGesture)
    }
    
    @objc func sha1Tapped() {
        self.selectAlgorithm(.sha1)
        self.tokenEntity.algorithm = .sha1
    }
    
    @objc func sha256Tapped() {
        self.selectAlgorithm(.sha256)
        self.tokenEntity.algorithm = .sha256
    }
    
    @objc func sha512Tapped() {
        self.selectAlgorithm(.sha512)
        self.tokenEntity.algorithm = .sha512
    }
}

//MARK: - Additional Options Configs
extension NewAccountViewController {
    private func selectedFactor(_ factor: TokenType) {
        switch factor {
        case .counter:
            self.timeBasedView.backgroundColor = .white
            self.counterBasedView.backgroundColor = Colors.cultured
            
            self.timeBasedLabel.textColor = Colors.graygray
            self.counterBasedLabel.textColor = Colors.outerSpace
        case .timer:
            self.timeBasedView.backgroundColor = Colors.cultured
            self.counterBasedView.backgroundColor = .white
            
            self.timeBasedLabel.textColor = Colors.outerSpace
            self.counterBasedLabel.textColor = Colors.graygray
        }
    }
    
    private func selectDigitsCount(_ digCount: DigitCount) {
        switch digCount {
        case .six:
            self.sixDigitsView.backgroundColor = Colors.cultured
            self.sevenDigitsView.backgroundColor = .white
            self.eightDigitsView.backgroundColor = .white
            
            self.sixDigitsLabel.textColor = Colors.outerSpace
            self.sevenDigitsLabel.textColor = Colors.graygray
            self.eightDigitsLabel.textColor = Colors.graygray
        case .seven:
            self.sixDigitsView.backgroundColor = .white
            self.sevenDigitsView.backgroundColor = Colors.cultured
            self.eightDigitsView.backgroundColor = .white
            
            self.sixDigitsLabel.textColor = Colors.graygray
            self.sevenDigitsLabel.textColor = Colors.outerSpace
            self.eightDigitsLabel.textColor = Colors.graygray
        case .eight:
            self.sixDigitsView.backgroundColor = .white
            self.sevenDigitsView.backgroundColor = .white
            self.eightDigitsView.backgroundColor = Colors.cultured
            
            self.sixDigitsLabel.textColor = Colors.graygray
            self.sevenDigitsLabel.textColor = Colors.graygray
            self.eightDigitsLabel.textColor = Colors.outerSpace
        }
    }
    
    private func selectAlgorithm(_ algorithm: Generator.Algorithm) {
        switch algorithm {
        case .sha1:
            self.sha1View.backgroundColor = Colors.cultured
            self.sha256View.backgroundColor = .white
            self.sha512View.backgroundColor = .white
            
            self.sha1Label.textColor = Colors.outerSpace
            self.sha256Label.textColor = Colors.graygray
            self.sha512Label.textColor = Colors.graygray
        case .sha256:
            self.sha1View.backgroundColor = .white
            self.sha256View.backgroundColor = Colors.cultured
            self.sha512View.backgroundColor = .white
            
            self.sha1Label.textColor = Colors.graygray
            self.sha256Label.textColor = Colors.outerSpace
            self.sha512Label.textColor = Colors.graygray
        case .sha512:
            self.sha1View.backgroundColor = .white
            self.sha256View.backgroundColor = .white
            self.sha512View.backgroundColor = Colors.cultured
            
            self.sha1Label.textColor = Colors.graygray
            self.sha256Label.textColor = Colors.graygray
            self.sha512Label.textColor = Colors.outerSpace
        }
    }
    
}
