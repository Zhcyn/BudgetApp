import UIKit
class BudgetPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var monthNames: [String] = []
    lazy var monthlyBudgets: [UIViewController] = {
        return [addMonthlyBudget(monthName: monthNames[0]),
                addMonthlyBudget(monthName: monthNames[1]),
                addMonthlyBudget(monthName: monthNames[2])]
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.dataSource = self
        if let firstViewController = monthlyBudgets.last {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    private func addMonthlyBudget(monthName: String) -> MonthlyBudgetViewController {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "MonthlyBudgetViewController") as? MonthlyBudgetViewController ?? MonthlyBudgetViewController()
        let strArr = monthName.split(separator: " ")
        viewController.month = String(strArr[0])
        viewController.year = String(strArr[1])
        return viewController
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = monthlyBudgets.index(of: viewController) else { return nil }
        let previousIndex = currentIndex - 1
        guard previousIndex >= 0 else { return nil }
        return monthlyBudgets[previousIndex]
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = monthlyBudgets.index(of: viewController) else { return nil }
        let nextIndex = currentIndex + 1
        guard monthlyBudgets.count > nextIndex else { return nil }
        return monthlyBudgets[nextIndex]
    }
}
