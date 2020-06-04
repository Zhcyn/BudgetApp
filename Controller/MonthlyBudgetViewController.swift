import UIKit
class MonthlyBudgetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var month: String = ""
    var year: String = ""
    var categories: [Category] = {
        return OverviewViewController.budget.categories
    }()
    @IBOutlet weak var monthProgressBar: UIProgressView!
    @IBOutlet weak var todayValueConstraint: NSLayoutConstraint!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var differenceLabel: UILabel!
    @IBOutlet weak var budgetHeaderView: UIView!
    @IBOutlet weak var budgetCategoriesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "CategoryTableViewCell", bundle: nil)
        budgetCategoriesTableView.register(nib, forCellReuseIdentifier: "CategoryTableViewCell")
        budgetHeaderView.layer.shadowColor = #colorLiteral(red: 0.4685588669, green: 0.4685588669, blue: 0.4685588669, alpha: 1)
        budgetHeaderView.layer.shadowOpacity = 1.0
        budgetHeaderView.layer.shadowOffset = CGSize.zero
        budgetHeaderView.layer.shadowRadius = 6
        if categories.count == 0 {
            budgetCategoriesTableView.isHidden = true
        }
        monthLabel.text = "\(month) \(year)"
        monthProgressBar.progress = OverviewViewController.budget.getProgress(categoryName: "All", month: month)
        monthProgressBar.trackTintColor = #colorLiteral(red: 0.862745098, green: 0.8509803922, blue: 0.8549019608, alpha: 1)
        monthProgressBar.progressTintColor = #colorLiteral(red: 0, green: 0.7675034874, blue: 0.2718033226, alpha: 0.7043225365)
        let totalSpent = OverviewViewController.budget.getTotalSpent(monthName: month)
        let totalLimit = OverviewViewController.budget.totalLimit
        let difference = totalSpent - totalLimit
        differenceLabel.text = "$\(abs(difference)) " + (totalSpent <= 0 ? "Left" : difference <= 0 ? "Left" : "Over")
        progressLabel.text = "$\(totalSpent) of $\(totalLimit)"
        todayValueConstraint.constant = ((UIScreen.main.bounds.width - 80.0) * OverviewViewController.budget.getTodayValue(categoryName: "All", month: month)) + 32.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as! CategoryTableViewCell
        let category = categories[indexPath.row]
        var temp: Float = 0.0
        for tran in OverviewViewController.budget.allTransactions.filter({$0.date.getMonthName() == month && $0.categoryName == category.name}) {
            temp += tran.amount
        }
        let total = Int(ceil(temp))
        let difference = total - category.limit
        cell.budgetProgress.progress = OverviewViewController.budget.getProgress(categoryName: category.name, month: month)
        cell.todayValueConstraint.constant = ((UIScreen.main.bounds.width - 80) * OverviewViewController.budget.getTodayValue(categoryName: category.name, month: month)) + 25.0
        cell.categoryLabel.text = category.name
        cell.progressLabel.text = "$\(total) of $\(category.limit)"
        cell.differenceLabel.text = "$\(abs(difference)) " + (total <= 0 ? "Left" : difference <= 0 ? "Left" : "Over")
        return cell
    }
}
