import UIKit
class AllTransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var transactionSearchBar: UISearchBar!
    @IBOutlet weak var allTransactionsTableView: UITableView!
    var monthlyTransactions = [[Transaction]]()
    var filteredMonthlyTransactions = [[Transaction]]()
    var selectedTransaction: Transaction?
    var selectedIndex: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        transactionSearchBar.backgroundColor = #colorLiteral(red: 0.4039215686, green: 0.5254901961, blue: 0.7176470588, alpha: 1)
        let nib = UINib(nibName: "TransactionTableViewCell", bundle: nil)
        allTransactionsTableView.register(nib, forCellReuseIdentifier: "TransactionTableViewCell")
    }
    override func viewWillAppear(_ animated: Bool) {
        reloadTransactions()
        selectedTransaction = nil
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTransactionView" {
            guard let destination = segue.destination as? TransactionViewController else { return }
            guard let selectedTransaction =  selectedTransaction else { return }
            destination.transaction = selectedTransaction
            destination.amount = selectedTransaction.amount
            destination.editingIndex = selectedIndex
            destination.hasUnsavedChanges = false
        }
    }
    @IBAction func addTransaction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toTransactionView", sender: self)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = transactionSearchBar.text?.lowercased(), !text.isEmpty {
            filteredMonthlyTransactions = []
            for transactions in monthlyTransactions {
                filteredMonthlyTransactions.append(transactions.filter({
                    $0.categoryName.lowercased().contains(text)
                    || $0.merchant.lowercased().contains(text)
                    || "\($0.amount)".contains(text) }))
            }
        } else {
            filteredMonthlyTransactions = monthlyTransactions
        }
        allTransactionsTableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return monthlyTransactions.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let date = filteredMonthlyTransactions[section].first?.date {
            return date.getMonthHeader()
        }
        return nil
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMonthlyTransactions[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        let transaction = filteredMonthlyTransactions[indexPath.section][indexPath.row]
        let transactionInfo = transaction.getAllInfo()
        cell.monthLabel.text = transactionInfo[0]
        cell.dayLabel.text = transactionInfo[1]
        cell.merchantLabel.text = transactionInfo[2]
        cell.categoryLabel.text = transactionInfo[3]
        cell.integerAmountLabel.text = transactionInfo[4]
        cell.decimalAmountLabel.text = transactionInfo[5]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = filteredMonthlyTransactions[indexPath.section][indexPath.row]
        let index = OverviewViewController.budget.allTransactions.firstIndex(where: { $0 == transaction })
        self.selectedTransaction = transaction
        self.selectedIndex = index
        performSegue(withIdentifier: "toTransactionView", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let transaction = filteredMonthlyTransactions[indexPath.section][indexPath.row]
            OverviewViewController.budget.removeTransaction(transaction: transaction)
            reloadTransactions()
        }
    }
    private func reloadTransactions() {
        let budget = OverviewViewController.budget
        monthlyTransactions = []
        for month in budget.getMonths() {
            let month = String(month.split(separator: " ")[0])
            let transactions = budget.allTransactions.filter({ $0.date.getMonthName() == month })
            if !transactions.isEmpty {
                monthlyTransactions.insert(transactions, at: 0)
            }
        }
        filteredMonthlyTransactions = monthlyTransactions
        allTransactionsTableView.reloadData()
    }
}
