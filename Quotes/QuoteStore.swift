import SwiftUI
import WidgetKit

enum AppTab: Hashable { case today, library, favorites, settings }

@MainActor
@Observable
final class QuoteStore {
    private(set) var favoriteIDs: Set<String> = []
    private(set) var customQuotes: [Quote] = []
    private(set) var hiddenBuiltInIDs: Set<String> = []
    private(set) var offset = 0
    private(set) var rotation: RefreshFrequency = .hourly
    /// A quote opened from the widget; shown on Today until the user moves on.
    var spotlight: Quote?
    var tab: AppTab = .today

    var appearance: AppearanceMode {
        didSet { UserDefaults.standard.set(appearance.rawValue, forKey: "appearance") }
    }

    init() {
        appearance = UserDefaults.standard.string(forKey: "appearance").flatMap(AppearanceMode.init) ?? .system
        reload()
    }

    func reload() {
        favoriteIDs = SharedStore.favoriteIDs
        customQuotes = SharedStore.customQuotes
        hiddenBuiltInIDs = SharedStore.hiddenBuiltInIDs
        offset = SharedStore.shuffleOffset
        rotation = SharedStore.rotation
    }

    // MARK: Library

    var allQuotes: [Quote] {
        customQuotes + QuoteLibrary.builtIn.filter { !hiddenBuiltInIDs.contains($0.id) }
    }
    var favorites: [Quote] { allQuotes.filter { favoriteIDs.contains($0.id) } }
    var deletedCount: Int { hiddenBuiltInIDs.count }

    func isFavorite(_ quote: Quote) -> Bool { favoriteIDs.contains(quote.id) }

    func toggleFavorite(_ quote: Quote) {
        if favoriteIDs.contains(quote.id) { favoriteIDs.remove(quote.id) } else { favoriteIDs.insert(quote.id) }
        SharedStore.favoriteIDs = favoriteIDs
        refreshWidgets()
    }

    func add(_ quote: Quote) {
        var quote = quote
        quote.isCustom = true
        customQuotes.insert(quote, at: 0)
        saveLibrary()
    }

    /// Saves changes to a quote. Editing a built-in quote turns it into your own copy.
    @discardableResult
    func update(_ quote: Quote) -> Quote {
        var saved = quote
        if let index = customQuotes.firstIndex(where: { $0.id == quote.id }) {
            customQuotes[index] = quote
        } else {
            var copy = quote
            copy.id = UUID().uuidString
            copy.isCustom = true
            hiddenBuiltInIDs.insert(quote.id)
            if favoriteIDs.remove(quote.id) != nil { favoriteIDs.insert(copy.id) }
            customQuotes.insert(copy, at: 0)
            if spotlight?.id == quote.id { spotlight = copy }
            saved = copy
        }
        if let current = spotlight, current.id == quote.id { spotlight = quote }
        saveLibrary()
        return saved
    }

    func delete(_ quote: Quote) {
        if quote.isCustom {
            customQuotes.removeAll { $0.id == quote.id }
        } else {
            hiddenBuiltInIDs.insert(quote.id)
        }
        favoriteIDs.remove(quote.id)
        if spotlight?.id == quote.id { spotlight = nil }
        saveLibrary()
    }

    func delete(_ quotes: [Quote]) {
        for quote in quotes { delete(quote) }
    }

    func restoreDeleted() {
        hiddenBuiltInIDs.removeAll()
        saveLibrary()
    }

    private func saveLibrary() {
        SharedStore.customQuotes = customQuotes
        SharedStore.hiddenBuiltInIDs = hiddenBuiltInIDs
        SharedStore.favoriteIDs = favoriteIDs
        refreshWidgets()
    }

    // MARK: Rotation

    func setRotation(_ frequency: RefreshFrequency) {
        rotation = frequency
        SharedStore.rotation = frequency
        refreshWidgets()
    }

    func quote(at date: Date) -> Quote {
        if let spotlight { return spotlight }
        let slot = QuotePicker.slot(for: date, interval: rotation.interval)
        return QuotePicker.quote(in: allQuotes, slot: slot, offset: offset)
            ?? QuoteLibrary.builtIn[0]
    }

    /// When the quote shown at `date` will change on its own.
    func nextChange(after date: Date) -> Date {
        let slot = QuotePicker.slot(for: date, interval: rotation.interval)
        return QuotePicker.start(ofSlot: slot + 1, interval: rotation.interval)
    }

    /// Moves Today (and the widgets) forward or back by one quote.
    func step(_ delta: Int) {
        spotlight = nil
        offset += delta
        SharedStore.shuffleOffset = offset
        refreshWidgets()
    }

    func handle(_ url: URL) {
        guard url.scheme == "quotes", url.host() == "quote",
              let quote = allQuotes.first(where: { $0.id == url.lastPathComponent }) else { return }
        spotlight = quote
        tab = .today
    }

    private func refreshWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
