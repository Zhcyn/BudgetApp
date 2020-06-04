import UIKit
class OverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    static var budget: Budget {
        return getBudget()
    }
    var currentMonth: String = ""
    var numberOfRecentTransactions = 5
    var selectedIndex: Int?
    @IBOutlet weak var budgetView: UIView!
    @IBOutlet weak var budgetProgress: UIProgressView!
    @IBOutlet weak var todayValueConstraint: NSLayoutConstraint!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var recentTransactionsLabel: UILabel!
    @IBOutlet weak var recentTransactionsTableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "TransactionTableViewCell", bundle: nil)
        recentTransactionsTableview.register(nib, forCellReuseIdentifier: "TransactionTableViewCell")
        recentTransactionsTableview.isScrollEnabled = false
        currentMonth = OverviewViewController.budget.currentDate.getMonthName()
        budgetProgress.transform = budgetProgress.transform.scaledBy(x: 1, y: 8)
        budgetProgress.trackTintColor = #colorLiteral(red: 0.862745098, green: 0.8509803922, blue: 0.8549019608, alpha: 1)
        budgetProgress.progressTintColor = #colorLiteral(red: 0, green: 0.7675034874, blue: 0.2718033226, alpha: 0.7043225365)
        budgetProgress.progress = OverviewViewController.budget.getProgress(categoryName: "All", month: currentMonth)
        monthLabel.text = "\(currentMonth) Budget"
        todayValueConstraint.constant = ((UIScreen.main.bounds.width - 72) * OverviewViewController.budget.getTodayValue(categoryName: "All", month: currentMonth)) + 20.0
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.budgetViewTapped(_: )))
        budgetView.addGestureRecognizer(gesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        budgetProgress.progress = OverviewViewController.budget.getProgress(categoryName: "All", month: currentMonth)
        todayValueConstraint.constant = ((UIScreen.main.bounds.width - 72) * OverviewViewController.budget.getTodayValue(categoryName: "All", month: currentMonth)) + 20.0
        selectedIndex = nil
        recentTransactionsTableview.reloadData()
    }
    @objc private func budgetViewTapped(_ sender: UIGestureRecognizer) {
        performSegue(withIdentifier: "toBudgetDetail", sender: self)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UIScreen.main.bounds.height < 600 {
            numberOfRecentTransactions = 3
        } else if UIScreen.main.bounds.height < 700 {
            numberOfRecentTransactions = 4
        } else {
            numberOfRecentTransactions = 5
        }
        return numberOfRecentTransactions
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return recentTransactionsTableview.frame.height / CGFloat(numberOfRecentTransactions)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        if indexPath.row < OverviewViewController.budget.allTransactions.count {
            let transaction = OverviewViewController.budget.allTransactions[indexPath.row]
            let transactionInfo = transaction.getAllInfo()
            cell.monthLabel.text = transactionInfo[0]
            cell.dayLabel.text = transactionInfo[1]
            cell.merchantLabel.text = transactionInfo[2]
            cell.categoryLabel.text = transactionInfo[3]
            cell.integerAmountLabel.text = transactionInfo[4]
            cell.decimalAmountLabel.text = transactionInfo[5]
            cell.isUserInteractionEnabled = true
        } else {
            cell.isUserInteractionEnabled = false
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "toTransaction", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let budget = OverviewViewController.budget
            let transaction = budget.allTransactions[indexPath.row]
            OverviewViewController.budget.removeTransaction(transaction: transaction)
            recentTransactionsTableview.reloadData()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTransaction" {
            let backItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: nil)
            navigationItem.backBarButtonItem = backItem
            navigationItem.backBarButtonItem?.tintColor = UIColor.white
        } else if segue.identifier == "toBudgetDetail" {
            let backItem = UIBarButtonItem(title: "Overview", style: .done, target: self, action: nil)
            navigationItem.backBarButtonItem = backItem
            navigationItem.backBarButtonItem?.tintColor = UIColor.white
            let destination = segue.destination as? BudgetPageViewController
            destination?.monthNames = OverviewViewController.budget.getMonths()
        } else if segue.identifier == "toAllTransactions" {
            let backItem = UIBarButtonItem(title: "Overview", style: .done, target: self, action: nil)
            navigationItem.backBarButtonItem = backItem
            navigationItem.backBarButtonItem?.tintColor = UIColor.white
        } else if segue.identifier == "toTransaction" {
            let backItem = UIBarButtonItem(title: "Overview", style: .done, target: self, action: nil)
            navigationItem.backBarButtonItem = backItem
            navigationItem.backBarButtonItem?.tintColor = UIColor.white
            guard let destination = segue.destination as? TransactionViewController else { return }
            let selectedTransaction = OverviewViewController.budget.allTransactions[selectedIndex ?? 0]
            destination.transaction = selectedTransaction
            destination.amount = selectedTransaction.amount
            destination.editingIndex = selectedIndex
            destination.hasUnsavedChanges = false
        }
    }
    static func getBudget() -> Budget {
        guard let budgetData = UserDefaults.standard.object(forKey: "budgetData") as? Data,
            let budget = NSKeyedUnarchiver.unarchiveObject(with: budgetData) as? Budget else {return Budget()}
        let now = Date()
        if budget.currentDate < now { 
            budget.updateDate()
        }
        return budget
    }
    static func deleteBudget() {
        UserDefaults.standard.removeObject(forKey: "budgetData")
    }
}
