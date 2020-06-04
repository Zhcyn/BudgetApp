import UIKit
class FrequencyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var delegate: FrequencyViewControllerDelegate?
    let frequencies = ["Never", "Daily", "Weekly", "Biweekly", "Monthly"]
    var frequency: Int?
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var referenceLabel: UILabel!
    @IBOutlet weak var frequencyPicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        frequencyPicker.selectRow(getFrequencyRow(), inComponent: 0, animated: true)
        frequencyLabel.text = "Repeat this transaction"
        referenceLabel.text = getFrequencyString()
    }
    @IBAction func saveFrequency(_ sender: UIBarButtonItem) {
        delegate?.sendFrequencyBack(frequency: frequency)
        self.navigationController?.popViewController(animated: true)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frequencies.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return frequencies[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            frequency = nil
        } else if row == 1 {
            frequency = 1
        } else if row == 2 {
            frequency = 7
        } else if row == 3 {
            frequency = 14
        } else {
            frequency = 30
        }
        referenceLabel.text = getFrequencyString()
    }
    private func getFrequencyString() -> String {
        var str = "Never"
        if frequency == 1 {
            str = "Every day"
        } else if frequency == 7 {
            str = "Every week"
        } else if frequency == 14 {
            str = "Every two weeks"
        } else if frequency == 30 {
            str = "Every month"
        }
        return str
    }
    private func getFrequencyRow() -> Int {
        if frequency == 1 {
            return 1
        } else if frequency == 7 {
            return 2
        } else if frequency == 14 {
            return 3
        } else if frequency == 30 {
            return 4
        } else {
            return 0
        }
    }
}
protocol FrequencyViewControllerDelegate {
    func sendFrequencyBack(frequency: Int?)
}
extension TransactionViewController: FrequencyViewControllerDelegate {
    func sendFrequencyBack(frequency: Int?) {
        self.transaction.frequency = frequency
        self.hasUnsavedChanges = true
    }
}
