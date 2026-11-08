import Foundation

enum QuoteCategory: String, Codable, CaseIterable, Identifiable {
    case wisdom, motivation, life, happiness, courage, love

    var id: String { rawValue }
    var title: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .wisdom: "lightbulb.fill"
        case .motivation: "flame.fill"
        case .life: "leaf.fill"
        case .happiness: "sun.max.fill"
        case .courage: "shield.fill"
        case .love: "heart.fill"
        }
    }
}

struct Quote: Identifiable, Codable, Hashable {
    var id: String
    var text: String
    var author: String
    var category: QuoteCategory
    var isCustom: Bool

    init(id: String = UUID().uuidString, text: String, author: String, category: QuoteCategory, isCustom: Bool = false) {
        self.id = id
        self.text = text
        self.author = author
        self.category = category
        self.isCustom = isCustom
    }

    var displayAuthor: String {
        let trimmed = author.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Unknown" : trimmed
    }

    var shareText: String { "“\(text)” — \(displayAuthor)" }
    var deepLink: URL { URL(string: "quotes://quote/\(id)")! }
}
