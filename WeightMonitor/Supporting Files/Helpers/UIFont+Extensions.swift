import UIKit

extension UIFont {
    enum AppFonts: String {
        case semibold = "SFProDisplay-Semibold"
        case medium = "SFProText-Medium"
        case regular = "SFProText-Regular"
    }
    
    static func appFont(_ style: AppFonts, withSize size: CGFloat) -> UIFont {
        guard let font = UIFont(name: style.rawValue, size: size) else {
            return UIFont.systemFont(ofSize: 12)
        }
        return font
    }
}

