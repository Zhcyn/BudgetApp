import Foundation
import UIKit
public class Budget: NSObject, NSCoding {
    var currentDate: Date
    var categories: [Category]
    var allTransactions: [Transaction]
    var reoccurringTransactions: [Transaction]
    var allMerchants: [String : String]
    var recentMerchants: [String]
    var totalLimit: Int {
        var total: Int = 0
        for cat in categories {
            total += cat.limit
        }
        return total
    }
    override init() {
        self.currentDate = Date()
        self.categories = []
        self.allTransactions = []
        self.reoccurringTransactions = []
        self.allMerchants = [:]
        self.recentMerchants = []
    }
    init(currentDate: Date, categories: [Category], allTransactions: [Transaction], reoccurringTransactions: [Transaction], allMerchants: [String : String], recentMerchants: [String]) {
        self.currentDate = currentDate
        self.categories = categories
        self.allTransactions = allTransactions
        self.reoccurringTransactions = reoccurringTransactions
        self.allMerchants = allMerchants
        self.recentMerchants = recentMerchants
    }
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let currentDate = aDecoder.decodeObject(forKey: "currentDate") as? Date,
            let categories = aDecoder.decodeObject(forKey: "categories") as? [Category],
            let allTransactions = aDecoder.decodeObject(forKey: "allTransactions") as? [Transaction],
            let reoccurringTransactions = aDecoder.decodeObject(forKey: "reoccurringTransactions") as? [Transaction],
        let allMerchants = aDecoder.decodeObject(forKey: "allMerchants") as? [String : String],
            let recentMerchants = aDecoder.decodeObject(forKey: "recentMerchants") as? [String] else {return nil}
        self.init(currentDate: currentDate, categories: categories, allTransactions: allTransactions, reoccurringTransactions: reoccurringTransactions, allMerchants: allMerchants, recentMerchants: recentMerchants)
    }
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(currentDate, forKey: "currentDate")
        aCoder.encode(categories, forKey: "categories")
        aCoder.encode(allTransactions, forKey: "allTransactions")
        aCoder.encode(reoccurringTransactions, forKey: "reoccurringTransactions")
        aCoder.encode(allMerchants, forKey: "allMerchants")
        aCoder.encode(recentMerchants, forKey: "recentMerchants")
    }
    func addCategory(category: Category) {
        categories.append(category)
        categories.sort(by: { $0.name < $1.name })
        saveBudget()
    }
    func addTransaction(transaction: Transaction) {
        allTransactions.append(transaction)
        allTransactions.sort(by: {$0.date > $1.date})
        addMerchant(transaction: transaction)
        saveBudget()
    }
    func addMerchant(transaction: Transaction) {
        allMerchants[transaction.merchant] = transaction.categoryName
        if let index = recentMerchants.index(of: transaction.merchant) {
            recentMerchants.remove(at: index)
        }
        recentMerchants.insert(transaction.merchant, at: 0)
        if allMerchants.count > 50 {
            cleanUpMerchants()
        }
    }
    func addReoccurringTransaction(transaction: Transaction) {
        if currentDate >= transaction.date {
            allTransactions.append(transaction)
        }
        reoccurringTransactions.append(transaction)
    }
    func removeTransaction(transaction: Transaction) {
        guard let index = allTransactions.firstIndex(where: { $0 == transaction }) else { return }
        allTransactions.remove(at: index)
        saveBudget()
    }
    func changeCategoryLimit(categoryName: String, newLimit: Int) {
        categories.first(where: { $0.name == categoryName })?.limit = newLimit
        saveBudget()
    }
    func updateDate() {
        currentDate = Date()
        manageAllTransactions()
        saveBudget()
    }
    func manageAllTransactions() {
        var dateComponent = DateComponents()
        dateComponent.month = -2
        var oldestKeptDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) ?? currentDate
        oldestKeptDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: oldestKeptDate) ?? currentDate
        allTransactions = allTransactions.filter { $0.date >= oldestKeptDate}
    }
    func manageReoccurringTransactions() {
        for transaction in reoccurringTransactions {
            if transaction.date <= currentDate {
                transaction.updateDate()
                allTransactions.append(transaction)
            } else {
                break
            }
        }
    }
    private func cleanUpMerchants() {
        let oldestMerchant = recentMerchants.remove(at: recentMerchants.endIndex)
        allMerchants.removeValue(forKey: oldestMerchant)
    }
    private func saveBudget() {
        let budgetData = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(budgetData, forKey: "budgetData")
    }
    func getTotalSpent(monthName: String) -> Int {
        var totalSpent: Float = 0.0
        for tran in allTransactions.filter({ $0.date.getMonthName() == monthName }) {
            totalSpent += tran.amount
        }
        return Int(ceil(totalSpent))
    }
    func getMonths() -> [String] {
        var dateComponent = DateComponents()
        dateComponent.month = -2
        var months = [Calendar.current.date(byAdding: dateComponent, to: currentDate)?.getMonthHeader() ?? ""]
        dateComponent.month = -1
        months += [Calendar.current.date(byAdding: dateComponent, to: currentDate)?.getMonthHeader() ?? ""]
        months += [currentDate.getMonthHeader()]
        return months
    }
    func getProgress(categoryName: String, month: String) -> Float {
        var total: Float = 0.0
        var limit: Float = 0.0
        if categoryName == "All" {
            for transaction in allTransactions.filter({ $0.date.getMonthName() == month }) {
                total += transaction.amount
            }
            limit = Float(totalLimit)
        } else {
            for transaction in allTransactions.filter({ $0.date.getMonthName() == month && $0.categoryName == categoryName }) {
                total += transaction.amount
            }
            limit = Float(categories.first(where: {$0.name == categoryName })?.limit ?? 0)
        }
        return total == 0.0 ? 0 : (total / limit) < 1.0 ? (total / limit) : 1.0
    }
    func getTodayValue(categoryName: String, month: String) -> CGFloat {
        guard let range = Calendar.current.range(of: .day, in: .month, for: currentDate) else { return 0.0 }
        let numDays = Float(range.count)
        guard currentDate.getMonthName() == month else { return 1.0 }
        var totalLimit: Float = 0.0
        var alreadySpent: Float = 0.0
        var yetToSpend: Float = 0.0
        if categoryName == "All" {
            for tran in allTransactions.filter({ $0.date.getMonthName() == month }) {
                alreadySpent += tran.amount
            }
            for recTran in reoccurringTransactions {
                var date = recTran.date
                while date < currentDate.lastDay {
                    if date > currentDate {
                        yetToSpend += recTran.amount
                    }
                    date = recTran.getNextDate(date: date)
                }
            }
            totalLimit = Float(self.totalLimit)
        } else {
            for tran in allTransactions.filter({ $0.date.getMonthName() == month && $0.categoryName == categoryName }) {
                alreadySpent += tran.amount
            }
            for recTran in reoccurringTransactions.filter({$0.categoryName == categoryName}) {
                var date = recTran.date
                while date < currentDate.lastDay {
                    if date > currentDate {
                        yetToSpend += recTran.amount
                    }
                    date = recTran.getNextDate(date: date)
                }
            }
            totalLimit = Float((categories.filter({$0.name == categoryName}).first)?.limit ?? 0)
        }
        guard totalLimit > 0 else { return 0.0 }
        guard yetToSpend <= totalLimit else { return 1.0 }
        let remainingLimit = totalLimit - yetToSpend
        return CGFloat(((remainingLimit / numDays) * Float(currentDate.day)) / totalLimit)
    }
}
    extension Date {
        var day: Int {
            return Calendar.current.component(.day, from: self)
        }
        var lastDay: Date {
            let components = Calendar.current.dateComponents([.year, .month], from: self)
            let firstDay = Calendar.current.date(byAdding: components, to: self) ?? Date()
            var dateComponents = DateComponents()
            dateComponents.month = 1
            dateComponents.day = -1
            return Calendar.current.date(byAdding: dateComponents, to: firstDay) ?? Date()
        }
        static func < (lhs: Date, rhs: Date) -> Bool {
            let order = Calendar.current.compare(lhs, to: rhs, toGranularity: .day)
            return order == .orderedAscending
        }
        func getMonthName() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            let strMonth = dateFormatter.string(from: self)
            return strMonth
        }
        func getDescription() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            let strMonth = dateFormatter.string(from: self)
            return strMonth
        }
        func getMonthHeader() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            let str = dateFormatter.string(from: self)
            return str
        }
}
