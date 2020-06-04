import Foundation
public class Category: NSObject, NSCoding {
    var name: String
    var limit: Int
    init(name: String, limit: Int) {
        self.name = name
        self.limit = limit
    }
    public required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "name") as? String else {return nil}
        self.init(name: name, limit: aDecoder.decodeInteger(forKey: "limit"))
    }
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(limit, forKey: "limit")
    }
}
