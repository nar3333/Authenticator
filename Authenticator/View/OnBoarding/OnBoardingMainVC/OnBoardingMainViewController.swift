//
//  OnBoardingMainViewController.swift
//  Authenticator
//
//  Created by PRO 14 on 13.11.23.
//

import UIKit
import ApphudSDK
import StoreKit

class OnBoardingMainViewController: UIViewController {
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var topSecondLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    var currentSlide = 0
    
    var product: ApphudProduct?
    var skProduct: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        self.setupCollection()
        self.configueSlides()
        self.getPurchases()
        self.closeButton.isHidden = true
    }
    
    private func getPurchases() {
//        dump(SubscriptionWrapper.shared.skProducts)
//        let skProd = SubscriptionWrapper.shared.skProducts.first { product in
//            return product.id == "com.narekghukasyan.Authenticator.week"
//        }
//        self.skProduct = skProd
        
        SubscriptionWrapper.shared.checkPaywalls { products in
            dump(products)
            let product = SubscriptionWrapper.shared.apphudProduct(for: .week)
            self.product = product
        }
//        self.skProduct = Apphud.product(productIdentifier: "com.narekghukasyan.Authenticator.week")
    }
    
    fileprivate func setupCollection() {
        self.imageCollection.dataSource = self
        self.imageCollection.delegate = self
        self.imageCollection.register(UINib(nibName: ImageCell.id, bundle: nil), forCellWithReuseIdentifier: ImageCell.id)
    }
    
    fileprivate func configueSlides() {
        self.closeButton.isHidden = self.currentSlide != 4
        
        if self.currentSlide == 1 {
            SKStoreReviewController.requestReviewInCurrentScene()
        }
        
        guard currentSlide >= 0 && currentSlide < ONBOARDITEMS.count else {return}
        
        let item = ONBOARDITEMS[currentSlide]
        self.topLabel.text = item.title
        if let bottomTitle = item.subtitle {
            self.topSecondLabel.isHidden = false
            self.topSecondLabel.text = bottomTitle
        } else {
            self.topSecondLabel.isHidden = true
        }
        
//        self.bottomLabel.text =
        if currentSlide == 4 {
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            let underlineAttributedString = NSAttributedString(string: item.secondaryTitle, attributes: underlineAttribute)
            self.bottomLabel.attributedText = underlineAttributedString
        } else {
            self.bottomLabel.attributedText = NSAttributedString(string: item.secondaryTitle, attributes: nil)
        }
        
        self.continueButton.setTitle(item.buttonTitle, for: .normal)
        self.imageCollection.reloadData()
    }
    
    //MARK: - IBActions
    @IBAction func continueAction(_ sender: Any) {
        self.continueToNextBoard()
//        self.continueToMain()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.continueToMain()
    }
    private func showPurchase() {
        guard let product else {
            print("Prd not found")
            return
        }
        SubscriptionWrapper.shared.purchase(product) { completed in
            print("Completed - ", completed)
            if completed {
                self.continueToMain()
            }
        }
//        self.getPurchases()
//        guard let skProduct else {
//            print("Product not found")
//            return
//        }
//        Task {
//            do {
//                try await SubscriptionWrapper.shared.purchase(skProduct)
//            } catch {
//                print("Couln't purchase")
//            }
//        }
//        guard let skProduct else {
//            print("product not found")
//            return
//        }
//        
//        SubscriptionWrapper.shared.purchase(product) { completed in
//            print("Completed - ", completed)
//            self.continueToMain()
//        }
    }
    
    
    
    private func continueToNextBoard() {
        if self.currentSlide == 4 {
            self.showPurchase()
        } else {
            self.currentSlide += 1
            main {
                self.configueSlides()
                self.imageCollection.scrollToItem(at: IndexPath(item: self.currentSlide, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    private func continueToMain() {
        AppDataManager.onBoardState = false
        let nav = UINavigationController()
        nav.isNavigationBarHidden = true
        nav.viewControllers = [MainViewController()]
        UIWindow.key.rootViewController = nav
        let options: UIView.AnimationOptions = .transitionCrossDissolve

        let duration: TimeInterval = 1

        UIView.transition(with: UIWindow.key, duration: duration, options: options, animations: {}, completion:
        { completed in
            print(completed)
        })
    }
    
    @IBAction func privacyAction(_ sender: Any) {
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
    
}

extension OnBoardingMainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ONBOARDITEMS.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.id, for: indexPath) as! ImageCell
        let item = ONBOARDITEMS[indexPath.item]
        cell.setImage(name: item.imageName)
        return cell
    }
}

extension OnBoardingMainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let wdth = collectionView.bounds.width
        return CGSize(width: wdth, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let item = scrollView.contentOffset.x / self.imageCollection.frame.width
        self.currentSlide = Int(item)
        main {
            self.configueSlides()
        }
    }
}
