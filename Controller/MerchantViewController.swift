import UIKit
class MerchantViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var delegate: MerchantViewControllerDelegate?
    var allMerchants: [String] = []
    var filteredAllMerchants: [String] = []
    var recentMerchants: [String] = []
    var filteredRecentMerchants: [String] = []
    var selectedMerchant: String?
    var isSearching: Bool {
        return merchantSearchBar.text != nil && merchantSearchBar.text != ""
    }
    @IBOutlet weak var merchantSearchBar: UISearchBar!
    @IBOutlet weak var merchantsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        merchantSearchBar.backgroundColor = #colorLiteral(red: 0.4039215686, green: 0.5254901961, blue: 0.7176470588, alpha: 1)
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        merchantsTableView.alwaysBounceVertical = false
        allMerchants = Array(OverviewViewController.budget.allMerchants.keys)
        recentMerchants = OverviewViewController.budget.recentMerchants
        filteredAllMerchants = allMerchants
        filteredRecentMerchants = recentMerchants
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if isSearching {
            filteredAllMerchants = allMerchants.filter({$0.contains(searchText) == true})
            filteredRecentMerchants = recentMerchants.filter({$0.contains(searchText) == true})
        } else {
            filteredAllMerchants = allMerchants
            filteredRecentMerchants = recentMerchants
        }
        merchantsTableView.reloadData()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 3
        if !isSearching { sections += -1 }
        if filteredRecentMerchants.count == 0 { sections += -1}
        if filteredAllMerchants.count < 5 { sections += -1}
        return sections
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching {
            if section == 1 {
                return "Recent Merchants"
            } else if section == 2 {
                return "All Merchants"
            } else {
                return ""
            }
        } else {
            if section == 0 {
                return "Recent Merchants"
            } else if section == 1 {
                return "All Merchants"
            } else {
                return ""
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            if section == 0 {
                return 1
            } else if section == 1 {
                return filteredRecentMerchants.count < 5 ? filteredRecentMerchants.count : 5
            } else if section == 2 {
                return filteredAllMerchants.count
            } else {
                return 0
            }
        } else {
            if section == 0 {
                return filteredRecentMerchants.count < 5 ? filteredRecentMerchants.count : 5
            } else if section == 1 {
                return filteredAllMerchants.count
            } else {
                return 0
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "merchantCell", for: indexPath)
        if isSearching {
            if indexPath.section == 0 {
                cell.textLabel?.text = "Create \"\(merchantSearchBar.text ?? "")\""
            } else if indexPath.section == 1 {
                cell.textLabel?.text = filteredRecentMerchants[indexPath.row]
            } else if indexPath.section == 2 {
                cell.textLabel?.text = filteredAllMerchants[indexPath.row]
            }
        } else {
            if indexPath.section == 0 {
                cell.textLabel?.text = filteredRecentMerchants[indexPath.row]
            } else if indexPath.section == 1 {
                cell.textLabel?.text = filteredAllMerchants[indexPath.row]
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            if indexPath.section == 0 {
                selectedMerchant = merchantSearchBar.text!
            } else if indexPath.section == 1 {
                selectedMerchant = filteredRecentMerchants[indexPath.row]
            } else if indexPath.section == 2 {
                selectedMerchant = filteredAllMerchants[indexPath.row]
            }
        } else {
            if indexPath.section == 0 {
                selectedMerchant = filteredRecentMerchants[indexPath.row]
            } else if indexPath.section == 1 {
                selectedMerchant = filteredAllMerchants[indexPath.row]
            }
        }
        let category = OverviewViewController.budget.allMerchants[selectedMerchant!]
        delegate?.sendMerchantBack(merchant: selectedMerchant!, category: category)
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
}
protocol MerchantViewControllerDelegate {
    func sendMerchantBack(merchant: String, category: String?)
}
extension TransactionViewController: MerchantViewControllerDelegate {
    func sendMerchantBack(merchant: String, category: String?) {
        self.transaction.merchant = merchant
        if category != nil {
            self.transaction.categoryName = category!
        }
        self.hasUnsavedChanges = true
    }
}
