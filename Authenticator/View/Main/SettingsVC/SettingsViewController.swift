//
//  SettingsViewController.swift
//  Authenticator
//
//  Created by PRO 14 on 14.11.23.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var purchaseAdView: UIView!
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    private func setupUI() {
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        self.settingsTableView.register(UINib(nibName: SettingsCell.id, bundle: nil), forCellReuseIdentifier: SettingsCell.id)
        self.settingsTableView.register(UINib(nibName: SwitchSettingsCell.id, bundle: nil), forCellReuseIdentifier: SwitchSettingsCell.id)
        self.settingsTableView.sectionHeaderTopPadding = 0
        
        self.purchaseAdView.isHidden = SubscriptionWrapper.shared.isSubscribed()
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func upgradeAction(_ sender: Any) {
        let vc = SecondaryPaywallViewController()
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(vc, animated: true)
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

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        let itemIndex = section == 0 ? row:row + 2
        let item = SETTINGSITEMS[itemIndex]
        
        switch section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.id, for: indexPath) as! SwitchSettingsCell
                cell.setItem(item)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.id, for: indexPath) as! SettingsCell
                cell.setItem(item)
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.id, for: indexPath) as! SettingsCell
            cell.hideArrow()
            cell.setItem(item)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRectMake(0, 0, tableView.bounds.size.width, 20))
        let lblHeader = UILabel.init(frame: CGRectMake(15, 0, tableView.bounds.size.width - 10, 20))
        
        switch section {
        case 0:
            lblHeader.text = "App settings"
        case 1:
            lblHeader.text = "General"
        default:
            lblHeader.text = ""
        }
        
        lblHeader.font = .poppinsMedium(size: 10)
        lblHeader.textColor = Colors.graygray
        headerView.addSubview(lblHeader)
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        77
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                print("Something")
            case 1:
                if SubscriptionWrapper.shared.isSubscribed() {
                    let vc = PassCodeViewController()
                    vc.passState = .create
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    showPurchaseView()
                }
            default:
                print("Something")
            }
        }
    }
    
    private func showPurchaseView() {
        let vc = MainPaywallViewController()
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(vc, animated: true)
    }
}
