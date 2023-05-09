import UIKit

final class AddWeightViewController: UIViewController {
    private var showSecondCell = false
    var currentDate: String?
    var currentWeight: String?
    var isEditVC: Bool?
    weak var delegateTransition: ScreenTransitionProtocol?
    var originalsaveButtonY: CGFloat = 0
    
    private let swipeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2.5
        view.backgroundColor = .swipeIndicatorColor
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Добавить вес"
        label.font = UIFont.appFont(.semibold, withSize: 20) //TODO: text BOLD FONT
        label.textColor = .blackDayColor
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(AddWeightTableViewCell.self, forCellReuseIdentifier: AddWeightTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .modalVCBgColor
        
        return tableView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.appFont(.medium, withSize: 17)
        button.backgroundColor = .purpleAnyAppearanceColor
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .modalVCBgColor
        
        addSubviews()
        addConstraints()
        registerForKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        originalsaveButtonY = saveButton.frame.origin.y
    }
    
    deinit {
        removeKeyBoardNotifications()
    }
    
    @objc private func saveButtonTapped() {
        saveWeight()
        dismiss(animated: true)
    }
    
    private func saveWeight() {
        let date = currentDate.flatMap { DateHelper().dateFormatterFromString.date(from: $0) } ?? Date()
        let record: WeightRecord
        guard let currentWeight = currentWeight,
              let weight = Double(currentWeight)
        else { return }
        
        switch MetricSystemStorage().metricSystem {
        case .metricUnit:
            record = WeightRecord(weight: weight, date: date)
        case .imperialUnit:
            record = WeightRecord(weight: weight / 2.20462, date: date)
        }
        
        if isEditVC == true {
            delegateTransition?.onTransition(value: record, key: "editRecord")
            isEditVC = false
        } else {
            delegateTransition?.onTransition(value: record, key: "newRecord")
        }
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func kbWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keuboardFrameSize = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        saveButton.frame.origin.y = originalsaveButtonY + CGFloat(-keuboardFrameSize.height)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc private func kbWillHide() {
        saveButton.frame.origin.y = originalsaveButtonY
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func removeKeyBoardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func addSubviews() {
        view.addSubview(swipeView)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(saveButton)
    }
    
    private func addConstraints() {
        swipeView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            swipeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            swipeView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            swipeView.heightAnchor.constraint(equalToConstant: 5),
            swipeView.widthAnchor.constraint(equalToConstant: 38),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 56),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.size.height * 166 / 812),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.5),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.5),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

extension AddWeightViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.endEditing(true)
        if indexPath.row == 0 {
            showSecondCell.toggle()
            tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
    }
    
    func hidePicker() {
        showSecondCell = false
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    }
}

extension AddWeightViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddWeightTableViewCell.reuseIdentifier, for: indexPath) as? AddWeightTableViewCell else { return UITableViewCell() }
        cell.delegateTransition = self
        
        switch indexPath.row {
        case 0:
            cell.datePicker.isHidden = true
            cell.leadingLabel.isHidden = false
            cell.trailingLabel.isHidden = false
            if let date = currentDate {
                cell.trailingLabel.text = date.trimmingCharacters(in: CharacterSet(charactersIn: "0"))
            } else {
                cell.trailingLabel.text = "Сегодня"
            }
            
            let accessoryChevron = UIImageView(
                image: UIImage(
                    systemName: "chevron.forward",
                    withConfiguration: UIImage.SymbolConfiguration(
                        pointSize: 11.44,
                        weight: .semibold
                    )
                )
            )
            accessoryChevron.tintColor = .blackDayColor
            cell.accessoryView = accessoryChevron
        case 1:
            cell.leadingLabel.isHidden = true
            cell.trailingLabel.isHidden = true
            cell.accessoryView = .none
            cell.datePicker.isHidden = false
            if let currentDate = currentDate {
                if let date = DateHelper().dateFormatterFull.date(from: currentDate) {
                    cell.datePicker.date = date
                }
            }
            cell.isHidden = !showSecondCell
        case 2:
            cell.trailingLabel.isHidden = false
            cell.trailingLabel.text = MetricSystemStorage().metricSystem.rawValue
            cell.trailingLabel.font = UIFont.appFont(.medium, withSize: 17)
            cell.trailingLabel.textColor = .secondaryTextColor
            cell.textField.isHidden = false
            cell.textField.placeholder = currentWeight
            if isEditVC == true {
                cell.textField.text = currentWeight
            }
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 50
        case 1:
            return showSecondCell ? 216 : 0
        case 2:
            return 72
        default:
            return 0
        }
    }
}

extension AddWeightViewController: ScreenTransitionProtocol {
    func onTransition<T>(value: T, key: String) {
        switch key {
        case "textFieldDidBeginEditing":
            hidePicker()
        case "currentDate":
            currentDate = value as? String
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        case "choosingWeight":
            currentWeight = value as? String
        default:
            break
        }
    }
}
