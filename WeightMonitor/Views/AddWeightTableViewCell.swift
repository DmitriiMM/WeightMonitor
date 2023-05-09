import UIKit

final class AddWeightTableViewCell: UITableViewCell {
    static let reuseIdentifier = "AddWeightTableViewCell"
    weak var delegateTransition: ScreenTransitionProtocol?
    
    lazy var leadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Дата"
        label.font = UIFont.appFont(.medium, withSize: 17)
        label.textColor = .blackDayColor
        label.isHidden = true
        
        return label
    }()
    
    lazy var trailingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.appFont(.regular, withSize: 17)
        label.textColor = .purpleColor
        label.isHidden = true
        
        return label
    }()
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.isHidden = true
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.addTarget(self, action: #selector(chooseDate(_:)), for: .valueChanged)
        
        return picker
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.appFont(.semibold, withSize: 34)
        textField.textColor = .blackDayColor
        textField.keyboardType = .decimalPad
        textField.delegate = self
        
        textField.isHidden = true
        
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .modalVCBgColor
        
        addSubviews()
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func chooseDate(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        if DateHelper().dateFormatterFull.string(from: sender.date) != DateHelper().dateFormatterFull.string(from: Date()) {
            delegateTransition?.onTransition(value: dateFormatter.string(from: sender.date), key: "currentDate")
        } else {
            delegateTransition?.onTransition(value: "Сегодня", key: "currentDate")
        }
    }
    
    private func addSubviews() {
        contentView.addSubview(leadingLabel)
        contentView.addSubview(trailingLabel)
        contentView.addSubview(datePicker)
        contentView.addSubview(textField)
    }
    
    private func addConstraints() {
        leadingLabel.translatesAutoresizingMaskIntoConstraints = false
        trailingLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.5),
            leadingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            trailingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            trailingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -16),
            datePicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

extension AddWeightTableViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegateTransition?.onTransition(value: true, key: "textFieldDidBeginEditing")
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegateTransition?.onTransition(value: textField.text, key: "choosingWeight")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        
        if currentText.isEmpty {
            if newText.starts(with: "0") || newText.starts(with: decimalSeparator) {
                return false
            }
        }
        
        let allowedCharacters = CharacterSet(charactersIn: "0123456789\(decimalSeparator)")
        let decimalCount = newText.components(separatedBy: decimalSeparator).count - 1
        let isNumericWithDecimal = allowedCharacters.isSuperset(of: CharacterSet(charactersIn: string)) && decimalCount <= 1
        if !isNumericWithDecimal {
            return false
        }
        
        if newText.count > 4 {
            return false
        }
        
        let components = newText.components(separatedBy: decimalSeparator)
        if decimalCount > 0 && components.last!.count > 1 {
            return false
        }
        
        if let index = newText.firstIndex(of: decimalSeparator.first!) {
            if newText.distance(from: newText.startIndex, to: index) == 3 {
                return false
            }
        }
        
        return true
    }
}



