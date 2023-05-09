import UIKit

final class HistoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = "HistoryTableViewCell"
    
    lazy var weightLabel = UILabel()
    lazy var diffLabel = UILabel()
    lazy var dateLabel = UILabel()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStackView() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(weightLabel)
        stackView.addArrangedSubview(diffLabel)
        stackView.addArrangedSubview(dateLabel)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        weightLabel.translatesAutoresizingMaskIntoConstraints = false
        diffLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            weightLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width * 116 / 375),
            diffLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width * 116 / 375),
            dateLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width * 71 / 375)
        ])
    }
}
