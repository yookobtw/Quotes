import Foundation

/// Storage shared between the app and the widget through an App Group.
enum SharedStore {
    static let appGroupID = "group.com.sayatamanzhol.Quotes"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    private enum Key {
        static let favorites = "favoriteIDs"
        static let custom = "customQuotes"
        static let hidden = "hiddenBuiltInIDs"
        static let offset = "shuffleOffset"
        static let rotation = "rotationInterval"
    }

    static var favoriteIDs: Set<String> {
        get { Set(defaults.stringArray(forKey: Key.favorites) ?? []) }
        set { defaults.set(newValue.sorted(), forKey: Key.favorites) }
    }

    static var customQuotes: [Quote] {
        get {
            guard let data = defaults.data(forKey: Key.custom) else { return [] }
            return (try? JSONDecoder().decode([Quote].self, from: data)) ?? []
        }
        set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: Key.custom)
        }
    }

    /// Built-in quotes the user deleted from their library.
    static var hiddenBuiltInIDs: Set<String> {
        get { Set(defaults.stringArray(forKey: Key.hidden) ?? []) }
        set { defaults.set(newValue.sorted(), forKey: Key.hidden) }
    }

    /// Bumped by "Next" buttons so the app and widget skip ahead together.
    static var shuffleOffset: Int {
        get { defaults.integer(forKey: Key.offset) }
        set { defaults.set(newValue, forKey: Key.offset) }
    }

    /// How often quotes change on their own (app + widgets set to "Same as App").
    static var rotation: RefreshFrequency {
        get {
            let stored = defaults.string(forKey: Key.rotation).flatMap(RefreshFrequency.init(rawValue:))
            return stored == nil || stored == .sameAsApp ? .hourly : stored!
        }
        set { defaults.set(newValue.rawValue, forKey: Key.rotation) }
    }

    static var allQuotes: [Quote] {
        let hidden = hiddenBuiltInIDs
        return customQuotes + QuoteLibrary.builtIn.filter { !hidden.contains($0.id) }
    }

    static func toggleFavorite(id: String) {
        var ids = favoriteIDs
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        favoriteIDs = ids
    }
}

/// Deterministic quote rotation so the app and widget agree on "the current quote".
enum QuotePicker {
    static func pool(for source: QuoteSource) -> [Quote] {
        let all = SharedStore.allQuotes
        switch source {
        case .all: return all
        case .favorites:
            let ids = SharedStore.favoriteIDs
            return all.filter { ids.contains($0.id) }
        case .mine: return all.filter(\.isCustom)
        default: return all.filter { $0.category == source.category }
        }
    }

    private static var tzOffset: TimeInterval { TimeInterval(TimeZone.current.secondsFromGMT()) }

    static func slot(for date: Date, interval: TimeInterval) -> Int {
        Int(floor((date.timeIntervalSince1970 + tzOffset) / interval))
    }

    static func start(ofSlot slot: Int, interval: TimeInterval) -> Date {
        Date(timeIntervalSince1970: Double(slot) * interval - tzOffset)
    }

    static func quote(in pool: [Quote], slot: Int, offset: Int) -> Quote? {
        guard !pool.isEmpty else { return nil }
        // Order by a stable hash so consecutive slots feel random but never change between launches.
        let ordered = pool.sorted { stableHash($0.id) < stableHash($1.id) }
        let count = ordered.count
        let index = ((slot + offset) % count + count) % count
        return ordered[index]
    }

    private static func stableHash(_ string: String) -> UInt64 {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in string.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return hash
    }
}
