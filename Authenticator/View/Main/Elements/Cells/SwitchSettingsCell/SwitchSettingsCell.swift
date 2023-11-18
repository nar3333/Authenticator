//
//  SwitchSettingsCell.swift
//  Authenticator
//
//  Created by PRO 14 on 14.11.23.
//

import UIKit

class SwitchSettingsCell: UITableViewCell {
    static let id = "SwitchSettingsCell"

    @IBOutlet weak var autolockSwitcher: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset.left = 15
        separatorInset.right = 15
        selectionStyle = .none
        self.autolockSwitcher.isOn = AppDataManager.enablePassCode
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func autolockSwithcerChanged(_ sender: UISwitch) {
        AppDataManager.enablePassCode = sender.isOn
    }
    
    func setItem(_ item: SettingsModel) {
        self.titleLabel.text = item.title
        self.iconImageView.image = UIImage(named: item.imageName)
    }
    
}
