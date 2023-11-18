//
//  GradientView.swift
//  Authenticator
//
//  Created by PRO 14 on 13.11.23.
//

import UIKit

class GradientView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let gradientLayer = layer as? CAGradientLayer {
            gradientLayer.colors = [Colors.blueberry, Colors.blueblue]
            gradientLayer.locations = [0.0, 1.0]
            gradientLayer.startPoint = .zero
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        }
    }
}
