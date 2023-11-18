//
//  ImageCell.swift
//  Authenticator
//
//  Created by PRO 14 on 13.11.23.
//

import UIKit

class ImageCell: UICollectionViewCell {
    static let id = "ImageCell"

    @IBOutlet weak var onboardImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setImage(name: String) {
        self.onboardImageView.image = UIImage(named: name)
    }

}
