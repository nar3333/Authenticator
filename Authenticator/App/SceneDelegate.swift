//
//  SceneDelegate.swift
//  Authenticator
//
//  Created by PRO 14 on 13.11.23.
//

import UIKit
import ApphudSDK
import StoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        self.setRoot()
        Task {
            await self.getProducts()
        }
        self.startAppHud()
    }
    
    private func getProducts() async{
        do {
//            let productRequest = SKProductsRequest(productIdentifiers: [
//                "com.narekghukasyan.Authenticator.week",
//                "com.narekghukasyan.Authenticator.month",
//                "com.narekghukasyan.Authenticator.year"])
            let products = try await Product.products(for: [
                "com.narekghukasyan.Authenticator.week",
                "com.narekghukasyan.Authenticator.month",
                "com.narekghukasyan.Authenticator.year",
                                            ])

            SubscriptionWrapper.shared.skProducts = products
        } catch {
            print("Product load error")
        }
    }
    
    private func startAppHud() {
        Apphud.start(apiKey: "app_KpSkPjnxcrikbGko7Xn9TZLze5ZGbY")
    }
    
    private func setRoot() {
        let onBoarding = AppDataManager.onBoardState
        
        let nav = UINavigationController()
        nav.isNavigationBarHidden = true
        
        if onBoarding {
            let vc = OnBoardingMainViewController()
            nav.viewControllers = [vc]
        } else {
            let vc = MainViewController()
            let code = AppDataManager.passCode
            var viewControllers: [UIViewController] = []
            if !code.isEmpty, code.count == 4, AppDataManager.enablePassCode {
                let passCodeVC = PassCodeViewController()
                passCodeVC.passState = .enter
                viewControllers = [vc, passCodeVC]
            } else {
                viewControllers = [vc]
            }
            nav.viewControllers = viewControllers
        }
        
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        
    }
}

