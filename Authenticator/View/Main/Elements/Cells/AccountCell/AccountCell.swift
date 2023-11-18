//
//  AccountCell.swift
//  Authenticator
//
//  Created by PRO 14 on 14.11.23.
//

import UIKit
import OneTimePassword

//protocol AccountCellDelegate: AnyObject {
//    func longPressed(_ index: IndexPath)
//}

class AccountCell: UICollectionViewCell {
    
    @IBOutlet weak var code1Label: UILabel!
    @IBOutlet weak var code2Label: UILabel!
    @IBOutlet weak var copiedToastView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var containerStackView: UIStackView!
    static let id = "AccountCell"
    
//    var index: IndexPath?
    var timer: Timer?
    var token: PersistentToken?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func setupUI() {
        
        // Check if a gesture recognizer is already added
        if self.gestureRecognizers == nil || self.gestureRecognizers?.isEmpty == true {
            // Add gesture recognizer to the subview
            let longPressCopyGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressedCopy(_:)))
            self.addGestureRecognizer(longPressCopyGesture)
        }
        
        //        self.progressView.
    }
    
    @objc func longPressedCopy(_ gestureRecognizer: UILongPressGestureRecognizer) {
//        UIPasteboard.general.string = (code1Label.text ?? "") + (code2Label.text ?? "")
//        self.copiedToastView.isHidden = false
//        main(delay: 1.5) {
//            self.copiedToastView.isHidden = true
//        }
        
        guard gestureRecognizer.state == .began else { return }

        let cell = gestureRecognizer.view as! AccountCell
        UIPasteboard.general.string = (cell.code1Label.text ?? "") + (cell.code2Label.text ?? "")
        cell.copiedToastView.isHidden = false

        // Create a timer to hide the toast view after 1.5 seconds
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: cell, selector: #selector(cell.hideToastView), userInfo: nil, repeats: false)
        cell.timer = timer
    }
    
    @objc func hideToastView() {
        self.copiedToastView.isHidden = true
    }
    
    func setToken(_ token: PersistentToken) {
        
        self.token = token
        //        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        //        self.setCredentials(token)
        self.setTokenFirstTime()
    }
    
    func setProgress(progress: Float, updateToken: Bool = false) {
        self.progressView.progress = progress
    }
    
    func setTokenFirstTime() {
        if let code = token?.token.currentPassword {
            let splitCap = code.count / 2
            
            let code1 = code.prefix(splitCap)
            let code2 = code.suffix(code.count - splitCap)
            
            self.code1Label.text = String(code1)
            self.code2Label.text = String(code2)
            
            self.accountName.text = token?.token.issuer
            self.contactLabel.text = token?.token.name
        }
    }
    
    func setCredentials(_ token: PersistentToken) {
        do {
            let code = try token.token.generator.password(at: Date())
            let splitCap = code.count / 2
            
            let code1 = code.prefix(splitCap)
            let code2 = code.suffix(code.count - splitCap)
            
            self.code1Label.text = String(code1)
            self.code2Label.text = String(code2)
            
            self.accountName.text = token.token.name
            self.contactLabel.text = token.token.issuer
        } catch {
            print("Something went wrong")
        }
    }
    
}
