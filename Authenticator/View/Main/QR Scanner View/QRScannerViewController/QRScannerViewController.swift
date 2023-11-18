//
//  QRScannerViewController.swift
//  Authenticator
//
//  Created by PRO 14 on 16.11.23.
//

import UIKit
import AVFoundation
import OneTimePassword

class QRScannerViewController: UIViewController {
    
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    private let scanner = QRScanner()
    private let videoLayer = AVCaptureVideoPreviewLayer()
    
    private var tokenFound: Bool = false
    
    let backgroundView = UIView()
    
    var checkPerm = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = self.backgroundView.superview {
            self.backgroundView.removeFromSuperview()
        }
        
        if checkPerm {
            self.checkPermission()
        }
    }
    
    func checkPermission() {
        switch QRScanner.authorizationStatus {
        case .notDetermined:
            QRScanner.requestAccess { [weak self] accessGranted in
                if accessGranted {
                    self?.startScanning()
                } else {
                    self?.showMissingAccessMessage()
                }
            }
        case .authorized:
            startScanning()
        default:
            // In the event of an unknown future enum case, fall back to manual entry.
            showMissingAccessMessage()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scanner.stop()
    }
    
    private func startScanning() {
        scanner.delegate = self
        scanner.start(success: { [weak self] captureSession in
            self?.videoLayer.session = captureSession
        }, failure: { [weak self] error in
            self?.scannerFailureAlert()
        })
    }
    
    private func scannerFailureAlert() {
        self.showAlert(title: "Something went wrong..", message: "Please, try later!")
    }

    private func showMissingAccessMessage() {
        let vc = CameraPermissionAlertViewController()
        vc.modalPresentationStyle = .overCurrentContext
        self.showDimmedBackground()
        vc.onClose = { action in
            self.hideDimmedBackground()
            switch action {
            case .cancel:
                self.navigationController?.popViewController(animated: true)
            case .openSettings:
                self.openAppSettings()
            }
        }
        self.navigationController?.present(vc, animated: true)
    }
    
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
    
    private func setupUI() {
        self.videoLayer.videoGravity = .resizeAspectFill
        self.videoLayer.frame = view.layer.bounds
        scannerView.layer.addSublayer(videoLayer)
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

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func flashAction(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension QRScannerViewController: QRScannerDelegate {
    func handleDecodedText(_ text: String) {
        guard !tokenFound else { return }
        
        guard let url = URL(string: text),
            let token = Token(url: url) else {
                // Show an error message
            self.showAlert(message: "Invalid Token")
            return
        }
        
        self.tokenFound = true
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let store = OTPManager.shared.getStore()
        do {
            try store.addToken(token)
            self.navigationController?.popViewController(animated: true)
        } catch {
            self.showAlert(title: "Something went wrong..", message: "Please, try later!")
        }
    }
}
