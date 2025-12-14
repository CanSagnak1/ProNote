import Foundation
import UIKit

struct Note: Codable, Identifiable {
    let id: UUID
    var title: String
    var content: String
    var dateCreated: Date
    var dateModified: Date
    var isFavorite: Bool
    var tintColorHex: String  // Store color as Hex

    // Computed property to get UIColor
    // Note: We don't store UIColor directly because it's not Codable by default
    var tintColor: UIColor {
        return UIColor(hex: tintColorHex)
    }

    init(
        id: UUID = UUID(), title: String, content: String, dateCreated: Date = Date(),
        dateModified: Date = Date(), isFavorite: Bool = false, tintColorHex: String = "#BB86FC"
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.isFavorite = isFavorite
        self.tintColorHex = tintColorHex
    }
}
