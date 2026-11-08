import AppIntents
import WidgetKit

enum QuoteSource: String, AppEnum, CaseIterable {
    case all, favorites, mine, wisdom, motivation, life, happiness, courage, love

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Quotes"

    static var caseDisplayRepresentations: [QuoteSource: DisplayRepresentation] = [
        .all: DisplayRepresentation(title: "All Quotes", image: .init(systemName: "quote.bubble.fill")),
        .favorites: DisplayRepresentation(title: "Favorites", image: .init(systemName: "heart.fill")),
        .mine: DisplayRepresentation(title: "My Quotes", image: .init(systemName: "pencil")),
        .wisdom: DisplayRepresentation(title: "Wisdom", image: .init(systemName: "lightbulb.fill")),
        .motivation: DisplayRepresentation(title: "Motivation", image: .init(systemName: "flame.fill")),
        .life: DisplayRepresentation(title: "Life", image: .init(systemName: "leaf.fill")),
        .happiness: DisplayRepresentation(title: "Happiness", image: .init(systemName: "sun.max.fill")),
        .courage: DisplayRepresentation(title: "Courage", image: .init(systemName: "shield.fill")),
        .love: DisplayRepresentation(title: "Love", image: .init(systemName: "heart.fill")),
    ]

    var category: QuoteCategory? { QuoteCategory(rawValue: rawValue) }
}

enum RefreshFrequency: String, AppEnum, CaseIterable, Identifiable {
    case sameAsApp, fifteenMinutes, thirtyMinutes, hourly, threeHours, sixHours, twelveHours, daily

    var id: String { rawValue }

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Frequency"

    static var caseDisplayRepresentations: [RefreshFrequency: DisplayRepresentation] = [
        .sameAsApp: "Same as App",
        .fifteenMinutes: "Every 15 Minutes",
        .thirtyMinutes: "Every 30 Minutes",
        .hourly: "Every Hour",
        .threeHours: "Every 3 Hours",
        .sixHours: "Every 6 Hours",
        .twelveHours: "Every 12 Hours",
        .daily: "Once a Day",
    ]

    /// Choices for the in-app setting (everything except "Same as App").
    static var appChoices: [RefreshFrequency] { allCases.filter { $0 != .sameAsApp } }

    var title: String {
        switch self {
        case .sameAsApp: "Same as App"
        case .fifteenMinutes: "Every 15 Minutes"
        case .thirtyMinutes: "Every 30 Minutes"
        case .hourly: "Every Hour"
        case .threeHours: "Every 3 Hours"
        case .sixHours: "Every 6 Hours"
        case .twelveHours: "Every 12 Hours"
        case .daily: "Once a Day"
        }
    }

    /// Resolves "Same as App" to the interval chosen in the app's settings.
    var resolved: RefreshFrequency {
        self == .sameAsApp ? SharedStore.rotation : self
    }

    var interval: TimeInterval {
        switch self {
        case .sameAsApp: SharedStore.rotation.interval
        case .fifteenMinutes: 15 * 60
        case .thirtyMinutes: 30 * 60
        case .hourly: 3600
        case .threeHours: 3 * 3600
        case .sixHours: 6 * 3600
        case .twelveHours: 12 * 3600
        case .daily: 24 * 3600
        }
    }
}

/// Interactive widget button: skip to the next quote.
struct NextQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Quote"
    static var description = IntentDescription("Shows a new quote in your widget.")

    func perform() async throws -> some IntentResult {
        SharedStore.shuffleOffset += 1
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

/// Interactive widget button: favorite / unfavorite the shown quote.
struct ToggleFavoriteIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Favorite"
    static var isDiscoverable: Bool = false

    @Parameter(title: "Quote ID") var quoteID: String

    init() {}
    init(quoteID: String) { self.quoteID = quoteID }

    func perform() async throws -> some IntentResult {
        SharedStore.toggleFavorite(id: quoteID)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
