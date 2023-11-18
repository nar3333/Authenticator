//
//  SettingsCell.swift
//  Authenticator
//
//  Created by PRO 14 on 14.11.23.
//

import UIKit

class SettingsCell: UITableViewCell {
    static let id = "SettingsCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset.left = 15
        separatorInset.right = 15
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func hideArrow() {
        self.arrowImageView.isHidden = true
    }
    
    func setItem(_ item: SettingsModel) {
        self.titleLabel.text = item.title
        self.iconImageView.image = UIImage(named: item.imageName)
    }
    
}
