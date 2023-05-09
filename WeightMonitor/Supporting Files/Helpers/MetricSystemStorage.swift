import Foundation

enum MetricSystem: String {
    case metricUnit = "кг"
    case imperialUnit = "lbs"
}

class MetricSystemStorage {
    private let userDefaults = UserDefaults.standard
    
    var metricSystem: MetricSystem {
        get {
            guard let storedValue = userDefaults.string(forKey: Keys.metricSystem.rawValue),
                  let metricSystem = MetricSystem(rawValue: storedValue)
            else {
                return .metricUnit
                
            }
            
            return metricSystem
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.metricSystem.rawValue)
        }
    }
    
    private enum Keys: String {
        case metricSystem
    }
    
    func store(metricSystem: MetricSystem) {
        self.metricSystem = metricSystem
    }
}
