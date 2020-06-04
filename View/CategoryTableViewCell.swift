import UIKit
class CategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var differenceLabel: UILabel!
    @IBOutlet weak var budgetProgress: UIProgressView!
    @IBOutlet weak var todayValueConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        budgetProgress.trackTintColor = #colorLiteral(red: 0.862745098, green: 0.8509803922, blue: 0.8549019608, alpha: 1)
        budgetProgress.progressTintColor = #colorLiteral(red: 0, green: 0.7675034874, blue: 0.2718033226, alpha: 0.7043225365)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
