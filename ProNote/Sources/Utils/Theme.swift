import UIKit

struct Theme {
    static let background = UIColor(hex: "#121212") // Very Dark Gray
    static let surface = UIColor(hex: "#1E1E1E")    // Slightly lighter for cards
    static let accent = UIColor(hex: "#BB86FC")     // Purple accent
    static let secondary = UIColor(hex: "#03DAC6")  // Teal
    static let textPrimary = UIColor(white: 0.95, alpha: 1.0)
    static let textSecondary = UIColor(white: 0.7, alpha: 1.0)
    
    static let cornerRadius: CGFloat = 16.0
    
    static func apply(to window: UIWindow) {
        window.tintColor = accent
        window.overrideUserInterfaceStyle = .dark
    }
}

extension UIColor {
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            self.init(white: 0.5, alpha: 1.0)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
