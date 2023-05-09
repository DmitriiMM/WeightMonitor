import UIKit

final class WidgetView: UIView {
    var currentWeight: Double?
    var diffWeight: Double?
    weak var delegateTransition: ScreenTransitionProtocol?
    
    private lazy var widgetLabel: UILabel = {
        let label = UILabel()
        label.text = "Текущий вес"
        label.font = UIFont.appFont(.medium, withSize: 13)
        label.textColor = .secondaryTextColor
        
        return label
    }()
    
    private lazy var currentWeightWidgetLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет записей"
        label.font = UIFont.appFont(.regular, withSize: 22)
        label.textColor = .blackDayColor
        
        return label
    }()
    
    private lazy var diffWidgetLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.appFont(.medium, withSize: 17)
        label.textColor = .secondaryTextColor.withAlphaComponent(0.6)
        
        return label
    }()
    
    private lazy var metricSystemWidgetLabel: UILabel = {
        let label = UILabel()
        label.text = "Метрическая система"
        label.font = UIFont.appFont(.medium, withSize: 17)
        label.textColor = .blackDayColor
        
        return label
    }()
    
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = .purpleColor
        switcher.isOn = true
        switcher.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        return switcher
    }()
    
    private lazy var logoImageView: UIImageView = {
        let image = UIImage(named: "logo")
        let imageView = UIImageView(image: image)
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .widgetBgColor
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubviews()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            delegateTransition?.onTransition(value: MetricSystem.metricUnit, key: "metricSystemShouldChange")
        } else {
            delegateTransition?.onTransition(value: MetricSystem.imperialUnit, key: "metricSystemShouldChange")
        }
    }
    
    func updateWidgetView(with system: MetricSystem) {
        switch system {
        case .metricUnit:
            metricSystemWidgetLabel.text = "Метрическая система"
            switcher.isOn = true
            
            guard let currentWeight = currentWeight else { return }
            currentWeightWidgetLabel.text = String(format: "%.1f", currentWeight) + " " + system.rawValue
            
            guard let diffWeight = diffWeight else { return }
            if diffWeight > 0 {
                diffWidgetLabel.text = "+" + String(format: "%.1f", diffWeight) + " " + system.rawValue
            } else {
                diffWidgetLabel.text = String(format: "%.1f", diffWeight) + " " + system.rawValue
            }
            
        case .imperialUnit:
            metricSystemWidgetLabel.text = "Имперская система"
            switcher.isOn = false
            
            guard let currentWeight = currentWeight else { return }
            currentWeightWidgetLabel.text = String(format: "%.1f", currentWeight * 2.20462) + " " + system.rawValue
            
            guard let diffWeight = diffWeight else { return }
            if diffWeight > 0 {
                diffWidgetLabel.text = "+" + String(format: "%.1f", diffWeight * 2.20462) + " " + system.rawValue
            } else {
                diffWidgetLabel.text = String(format: "%.1f", diffWeight * 2.20462) + " " + system.rawValue
            }
        }
    }
    
    private func addSubviews() {
        self.addSubview(widgetLabel)
        self.addSubview(currentWeightWidgetLabel)
        self.addSubview(diffWidgetLabel)
        self.addSubview(metricSystemWidgetLabel)
        self.addSubview(switcher)
        self.addSubview(logoImageView)
    }
    
    private func addConstraints() {
        widgetLabel.translatesAutoresizingMaskIntoConstraints = false
        currentWeightWidgetLabel.translatesAutoresizingMaskIntoConstraints = false
        diffWidgetLabel.translatesAutoresizingMaskIntoConstraints = false
        metricSystemWidgetLabel.translatesAutoresizingMaskIntoConstraints = false
        switcher.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            widgetLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            widgetLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            currentWeightWidgetLabel.leadingAnchor.constraint(equalTo: widgetLabel.leadingAnchor),
            currentWeightWidgetLabel.topAnchor.constraint(equalTo: widgetLabel.bottomAnchor, constant: 6),
            
            diffWidgetLabel.bottomAnchor.constraint(equalTo: currentWeightWidgetLabel.bottomAnchor),
            diffWidgetLabel.leadingAnchor.constraint(equalTo: currentWeightWidgetLabel.trailingAnchor, constant: 8),
            
            switcher.topAnchor.constraint(equalTo: currentWeightWidgetLabel.bottomAnchor, constant: 16),
            switcher.leadingAnchor.constraint(equalTo: currentWeightWidgetLabel.leadingAnchor),
            
            metricSystemWidgetLabel.centerYAnchor.constraint(equalTo: switcher.centerYAnchor),
            metricSystemWidgetLabel.leadingAnchor.constraint(equalTo: switcher.trailingAnchor, constant: 16),
            
            logoImageView.topAnchor.constraint(equalTo: self.topAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            logoImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 69 / 129),
            logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor, multiplier: 106 / 69)
        ])
    }
}
