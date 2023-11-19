//
//  MainViewController.swift
//  Authenticator
//
//  Created by PRO 14 on 13.11.23.
//

import UIKit
import OneTimePassword
import PhotosUI

class MainViewController: UIViewController {
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var placeholderImageView: UIImageView!
    
    @IBOutlet weak var accountCollection: UICollectionView!
    @IBOutlet weak var addAccountButton: UIButton!
    
    var timer: Timer?
    var timeCounter = 0.0
    
    let backgroundView = UIView()
    
    var tokens: [PersistentToken] = [] {
        didSet {
            if !tokens.isEmpty {
                var seconds = Date().seconds()
                if seconds > 30 {
                    seconds -= 30
                }
                self.timeCounter = Double(seconds)
                self.setupTimer()
            } else {
                timer?.invalidate()
            }
            let showPlaceholder = self.tokens.isEmpty
            self.accountCollection.isHidden = showPlaceholder
            self.addAccountButton.isHidden = !showPlaceholder
            self.placeholderImageView.isHidden = !showPlaceholder
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupData()
        if let _ = self.backgroundView.superview {
            self.backgroundView.removeFromSuperview()
        }
        main {
            self.accountCollection.reloadData()
        }
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    //    @objc func timerAction() {
    //        main {
    //            self.accountCollection.reloadData()
    //        }
    //    }
    
    @objc func timerAction() {
        timeCounter += 1.0
        
        if Int(timeCounter) % 3 == 0 {
            main {
                self.accountCollection.reloadData()
            }
        }
    }
    
    private func setupData() {
        self.tokens = OTPManager.shared.getAllTokens()
    }
    
    private func setupUI() {
        self.setupCollection()
        self.backgroundView.backgroundColor = .black.withAlphaComponent(0.3)
        self.grabAllPurchases()
    }
    
    private func grabAllPurchases() {
        SubscriptionWrapper.shared.checkPaywalls(completion: nil)
    }
    
    private func setupCollection() {
        self.accountCollection.delegate = self
        self.accountCollection.dataSource = self
        self.accountCollection.register(UINib(nibName: AccountCell.id, bundle: nil), forCellWithReuseIdentifier: AccountCell.id)
    }
    
    private func showDimmedBackground(with color: UIColor? = nil) {
        if let color {
            self.backgroundView.backgroundColor = color
        } else {
            self.backgroundView.backgroundColor = .black.withAlphaComponent(0.3)
        }
        self.navigationController?.view.addSubview(self.backgroundView)
        backgroundView.anchorToSuperview()
    }
    
    private func hideDimmedBackground() {
        if let _ = self.backgroundView.superview {
            self.backgroundView.removeFromSuperview()
        }
    }
    
    @IBAction func plusAction(_ sender: Any) {
        if SubscriptionWrapper.shared.isSubscribed() {
            self.showNewAccountAlert()
        } else {
            self.showPurchaseView()
        }
    }
    
    private func showNewAccountAlert() {
        let vc = NewAccountAlertViewController()
        vc.modalPresentationStyle = .overCurrentContext
        self.showDimmedBackground()
        vc.onClose = { action in
            self.hideDimmedBackground()
            switch action {
            case .cancel:
                print("Cancelled")
            case .qrScan:
                let vc = QRScannerViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            case .enterKey:
                let vc = NewAccountViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            case .gallery:
                self.showPHPicker()
                
            }
        }
        self.navigationController?.present(vc, animated: true)
    }
    
    private func showPHPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        
        let phPickerVC = PHPickerViewController(configuration: config)
        phPickerVC.modalPresentationStyle = .fullScreen
        phPickerVC.delegate = self
        self.present(phPickerVC, animated: true)
        
    }
    
    private func showPurchaseView() {
        let vc = MainPaywallViewController()
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(vc, animated: true)
    }
    
    @IBAction func settingsAction(_ sender: Any) {
        let settingsVC = SettingsViewController()
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.tokens.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccountCell.id, for: indexPath) as! AccountCell
        cell.setToken(tokens[indexPath.row])
        cell.hideToastView()
        
        let progressCount = timeCounter / 30.0
        print("progress - \(progressCount); time - \(timeCounter)")
        
        if timeCounter >= 30 {
            timeCounter = 0
            cell.setProgress(progress: 0.0, updateToken: true)
        } else {
            cell.setProgress(progress: Float(progressCount))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let token = self.tokens[indexPath.row]
        self.showDeletionAlert(token)
    }
    
    private func showDeletionAlert(_ token: PersistentToken) {
        let alertVC = UIAlertController(title: "Delete Accout", message: "Are you shure you want to delete this account?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { _ in
            do {
                try OTPManager.shared.getStore().deletePersistentToken(token)
                main {
                    self.setupData()
                    self.accountCollection.reloadData()
                }
            } catch {
                self.showAlert(title: "Something went wrong..", message: "Couldn't delete the token, please try later!")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)
        main {
            self.present(alertVC, animated: true)
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let wdth = (collectionView.frame.width - 10) / 2
        return CGSize(width: wdth, height: 130)
    }
}

extension MainViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        let result = results.first
        result?.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] object, error in
            guard let self = self, let image = object as? UIImage else {
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self else {return}
                self.processImageToGetQR(image)
            }
        })
    }
    
    private func processImageToGetQR(_ image: UIImage) {
        
        guard let qrCodeString = detectQRCode(image: image) else {
            main {
                self.showAlert(title: "Failure", message: "No QR code found in the image.")
            }
            return
        }
        guard let url = URL(string: qrCodeString),
              let token = Token(url: url) else {
            // Show an error message
            main {
                self.showAlert(message: "Invalid Token")
            }
            return
        }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let store = OTPManager.shared.getStore()
        do {
            try store.addToken(token)
            main {
                self.setupData()
                self.accountCollection.reloadData()
            }
        } catch {
            self.showAlert(title: "Something went wrong..", message: "Please, try later!")
        }
    }
    
    func detectQRCode(image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let context = CIContext()
        
        if let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options),
           let feature = detector.features(in: ciImage).first as? CIQRCodeFeature,
           let messageString = feature.messageString {
            
            return messageString
        }
        
        return nil
    }
    
    
}
