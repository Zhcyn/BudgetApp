import Foundation
public class Transaction: NSObject, NSCoding, NSCopying {
    var date: Date
    var merchant: String
    var amount: Float
    var categoryName: String
    var frequency: Int?
    var isSavable: Bool {
        return self.amount != 0.00 && self.categoryName != "" && self.merchant != ""
    }
    init(date: Date, merchant: String, amount: Float, categoryName: String, frequency: Int?) {
        self.date = date
        self.merchant = merchant
        self.amount = amount
        self.categoryName = categoryName
        self.frequency = frequency
    }
    public override init() {
        self.date = Date()
        self.amount = 0.00
        self.merchant = ""
        self.categoryName = ""
    }
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let date = aDecoder.decodeObject(forKey: "date") as? Date,
            let merchant = aDecoder.decodeObject(forKey: "merchant") as? String,
            let categoryName = aDecoder.decodeObject(forKey: "categoryName") as? String else {return nil}
        let frequency = aDecoder.decodeObject(forKey: "frequency") as? Int
        self.init(date: date, merchant: merchant, amount: aDecoder.decodeFloat(forKey: "amount"), categoryName: categoryName, frequency: frequency)
    }
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: "date")
        aCoder.encode(merchant, forKey: "merchant")
        aCoder.encode(amount, forKey: "amount")
        aCoder.encode(categoryName, forKey: "categoryName")
        aCoder.encode(frequency, forKey: "frequency")
    }
    public func copy(with zone: NSZone? = nil) -> Any {
        return Transaction(date: self.date, merchant: self.merchant, amount: self.amount, categoryName: self.categoryName, frequency: self.frequency)
    }
    func updateDate() {
        var dateComponent = DateComponents()
        if frequency == 1 {
            dateComponent.day = 1
        } else if frequency == 7 {
            dateComponent.day = 7
        } else if frequency == 14 {
            dateComponent.day = 14
        } else if frequency == 21 {
            dateComponent.day = 21
        } else if frequency == 30 {
            dateComponent.month = 1
        }
        self.date = Calendar.current.date(byAdding: dateComponent, to: self.date) ?? self.date
    }
    public func getNextDate(date: Date) -> Date {
        var dateComponent = DateComponents()
        if frequency == 1 {
            dateComponent.day = 1
        } else if frequency == 7 {
            dateComponent.day = 7
        } else if frequency == 14 {
            dateComponent.day = 14
        } else if frequency == 21 {
            dateComponent.day = 21
        } else if frequency == 30 {
            dateComponent.month = 1
        }
        return Calendar.current.date(byAdding: dateComponent, to: self.date) ?? self.date
    }
    public func getAllInfo() -> [String] {
        var infoArray: [String] = []
        let dateInfo = getDateInfo()
        infoArray += [dateInfo.0]
        infoArray += [dateInfo.1]
        infoArray += [merchant]
        infoArray += [categoryName]
        let amount = String(self.amount).split(separator: ".")
        let integer = "-$\(amount[0])"
        let decimal = String(amount[1]).count == 2 ? String(amount[1]) : String(amount[1]) + "0"
        infoArray += [integer]
        infoArray += [decimal]
        return infoArray
    }
    private func getDateInfo() -> (String, String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        let dateInfo = dateFormatter.string(from: self.date).split(separator: " ")
        return (String(dateInfo[0]), String(dateInfo[1]))
    }
    public func getFrequency() -> String {
        var str = "Never"
        if let frequency = self.frequency {
            if frequency == 1 {
                str = "Daily"
            } else if frequency == 7 {
                str = "Weekly"
            } else if frequency == 14 {
                str = "Biweekly"
            } else if frequency == 30 {
                str = "Monthly"
            }
        }
        return str
    }
    static func ==(lhs: Transaction, rhs: Transaction) -> Bool {
        guard lhs.amount == rhs.amount, lhs.categoryName == rhs.categoryName, lhs.date == rhs.date,
            lhs.frequency == rhs.frequency, lhs.merchant == rhs.merchant else { return false }
        return true
    }
}
