//
//  MainPaywallViewController.swift
//  Authenticator
//
//  Created by PRO 14 on 18.11.23.
//

import UIKit
import ApphudSDK

class MainPaywallViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var yearSubtitleLabel: UILabel!
    @IBOutlet weak var yearTitleLabel: UILabel!
    
    @IBOutlet weak var weekSubtitleLabel: UILabel!
    @IBOutlet weak var weekTitleLabel: UILabel!
    
    @IBOutlet weak var monthTitleLabel: UILabel!
    @IBOutlet weak var monthSubtitleLabel: UILabel!
    
    @IBOutlet weak var subscribeButton: UIButton!
    
    @IBOutlet weak var yearCheckMark: UIImageView!
    @IBOutlet weak var weekCheckMark: UIImageView!
    @IBOutlet weak var monthCheckMark: UIImageView!
    
    @IBOutlet weak var yearStackContainer: UIStackView!
    @IBOutlet weak var monthStackContainer: UIStackView!
    @IBOutlet weak var weekStackContainer: UIStackView!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var policyButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    let checkOnImage = UIImage(named: "checkmark_on")
    let checkOffImage = UIImage(named: "checkmark_off")
    
    var selectedSubscription: SubscriptionType = .month
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        self.setupSubscrElements()
        self.setupPurchases()
        self.selectCurrentSubscr()
    }
    
    private func setupPurchases() {
        SubscriptionWrapper.shared.checkPaywalls(completion: { _ in
            main(delay: 0.5) {
                print("WEEK")
                let weekPrice = SubscriptionWrapper.shared.product(for: .week)?.priceString ?? ""
                self.weekTitleLabel.text = "\(weekPrice) per week"
                
                print("MONTH")
                let monthPrice = SubscriptionWrapper.shared.product(for: .month)?.priceString ?? ""
                self.monthTitleLabel.text = "\(monthPrice) per month"
                
                print("YEAR")
                let yearPrice = SubscriptionWrapper.shared.product(for: .year)?.priceString ?? ""
                self.yearTitleLabel.text = "\(yearPrice) per year"
            }
        })
    }
    
    private func setupSubscrElements() {
        
        let weekTap = UITapGestureRecognizer(target: self, action: #selector(weekTapped))
        self.weekStackContainer.addGestureRecognizer(weekTap)
        
        let monthTap = UITapGestureRecognizer(target: self, action: #selector(monthTapped))
        self.monthStackContainer.addGestureRecognizer(monthTap)
        
        let yearTap = UITapGestureRecognizer(target: self, action: #selector(yearTapped))
        self.yearStackContainer.addGestureRecognizer(yearTap)
    }
    
    @objc func weekTapped() {
        self.selectedSubscription = .week
        self.selectCurrentSubscr()
    }
    
    @objc func monthTapped() {
        self.selectedSubscription = .month
        self.selectCurrentSubscr()
    }
    
    @objc func yearTapped() {
        self.selectedSubscription = .year
        self.selectCurrentSubscr()
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
    
    @IBAction func policyAction(_ sender: Any) {
    }
    
    @IBAction func subscribeAction(_ sender: Any) {
        self.makePurchase()
    }
    
    private func makePurchase() {
        var product: ApphudProduct?
        switch self.selectedSubscription {
        case .week:
            product = SubscriptionWrapper.shared.apphudProduct(for: .week)
        case .month:
            product = SubscriptionWrapper.shared.apphudProduct(for: .month)
        case .year:
            product = SubscriptionWrapper.shared.apphudProduct(for: .year)
        }
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

    
    @IBAction func termsAction(_ sender: Any) {
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

//MARK: - Configure Purchase Items
extension MainPaywallViewController {
    
    private func selectCurrentSubscr() {
        self.selectSubscription(for: self.selectedSubscription)
    }
    
    private func selectSubscription(for type: SubscriptionType) {
        self.weekSubscription(type == .week)
        self.monthSubscription(type == .month)
        self.yearSubscription(type == .year)
    }
    
    func weekSubscription(_ selected: Bool) {
        self.weekStackContainer.backgroundColor = selected ? Colors.vividYellow:Colors.blueberry
        self.weekStackContainer.viewBorderWidth = selected ? 0:1
        self.weekStackContainer.viewBorderColor = .white
        self.weekTitleLabel.textColor = selected ? Colors.outerSpace:.white
        self.weekSubtitleLabel.textColor = selected ? .white:Colors.graygray
        self.weekCheckMark.image = selected ? checkOnImage:checkOffImage
    }
    
    func monthSubscription(_ selected: Bool) {
        self.monthStackContainer.backgroundColor = selected ? Colors.vividYellow:Colors.blueberry
        self.monthStackContainer.viewBorderWidth = selected ? 0:1
        self.monthStackContainer.viewBorderColor = .white
        self.monthTitleLabel.textColor = selected ? Colors.outerSpace:.white
        self.monthSubtitleLabel.textColor = selected ? .white:Colors.graygray
        self.monthCheckMark.image = selected ? checkOnImage:checkOffImage
    }
    
    func yearSubscription(_ selected: Bool) {
        self.yearStackContainer.backgroundColor = selected ? Colors.vividYellow:Colors.blueberry
        self.yearStackContainer.viewBorderWidth = selected ? 0:1
        self.yearStackContainer.viewBorderColor = .white
        self.yearTitleLabel.textColor = selected ? Colors.outerSpace:.white
        self.yearSubtitleLabel.textColor = selected ? .white:Colors.graygray
        self.yearCheckMark.image = selected ? checkOnImage:checkOffImage
    }
    
}
