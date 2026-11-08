import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Configuration

struct QuoteWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Quote"
    static var description = IntentDescription("Choose which quotes appear and how often they change.")

    @Parameter(title: "Show", default: .all)
    var source: QuoteSource

    @Parameter(title: "New Quote", default: .sameAsApp)
    var frequency: RefreshFrequency
}

// MARK: - Timeline

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: Quote?
    let source: QuoteSource
    let isFavorite: Bool
}

struct QuoteProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: .now, quote: QuoteLibrary.builtIn[2], source: .all, isFavorite: false)
    }

    func snapshot(for configuration: QuoteWidgetIntent, in context: Context) async -> QuoteEntry {
        if context.isPreview { return placeholder(in: context) }
        return makeEntries(for: configuration, count: 1).first ?? placeholder(in: context)
    }

    func timeline(for configuration: QuoteWidgetIntent, in context: Context) async -> Timeline<QuoteEntry> {
        // Cover the next day, capped so the timeline stays small.
        let interval = configuration.frequency.interval
        let count = min(100, max(2, Int(86_400 / interval) + 1))
        return Timeline(entries: makeEntries(for: configuration, count: count), policy: .atEnd)
    }

    private func makeEntries(for configuration: QuoteWidgetIntent, count: Int) -> [QuoteEntry] {
        let interval = configuration.frequency.interval
        let pool = QuotePicker.pool(for: configuration.source)
        let favorites = SharedStore.favoriteIDs
        let offset = SharedStore.shuffleOffset
        let now = Date.now
        let firstSlot = QuotePicker.slot(for: now, interval: interval)

        return (0..<count).map { i in
            let slot = firstSlot + i
            let quote = QuotePicker.quote(in: pool, slot: slot, offset: offset)
            return QuoteEntry(
                date: i == 0 ? now : QuotePicker.start(ofSlot: slot, interval: interval),
                quote: quote,
                source: configuration.source,
                isFavorite: quote.map { favorites.contains($0.id) } ?? false
            )
        }
    }
}

// MARK: - Views

struct QuoteWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: QuoteEntry

    private var category: QuoteCategory {
        entry.quote?.category ?? entry.source.category ?? .wisdom
    }

    var body: some View {
        Group {
            if let quote = entry.quote {
                switch family {
                case .accessoryInline:
                    Text("“\(quote.text)”")
                case .accessoryRectangular:
                    RectangularQuoteView(quote: quote)
                case .systemSmall:
                    SmallQuoteView(quote: quote)
                case .systemLarge:
                    LargeQuoteView(quote: quote, isFavorite: entry.isFavorite)
                default:
                    MediumQuoteView(quote: quote, isFavorite: entry.isFavorite)
                }
            } else {
                EmptyQuoteView(source: entry.source)
            }
        }
        .containerBackground(for: .widget) {
            Rectangle()
                .fill(category.gradient)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "quote.closing")
                        .font(.system(size: 140, weight: .black))
                        .foregroundStyle(Palette.ink.opacity(0.07))
                        .offset(x: 24, y: 30)
                }
        }
        .widgetURL(entry.quote?.deepLink)
    }
}

private struct QuoteMark: View {
    var size: CGFloat
    var body: some View {
        Image(systemName: "quote.opening")
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(Palette.ink.opacity(0.6))
            .widgetAccentable()
    }
}

private struct SmallQuoteView: View {
    let quote: Quote
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            QuoteMark(size: 15)
            Text(quote.text)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .minimumScaleFactor(0.5)
                .layoutPriority(1)
            Spacer(minLength: 0)
            Text(quote.displayAuthor)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Palette.ink.opacity(0.8))
                .lineLimit(1)
        }
        .foregroundStyle(Palette.ink)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct MediumQuoteView: View {
    let quote: Quote
    let isFavorite: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            QuoteMark(size: 16)
            Text(quote.text)
                .font(.system(size: 19, weight: .semibold, design: .serif))
                .minimumScaleFactor(0.55)
                .layoutPriority(1)
            Spacer(minLength: 0)
            HStack(alignment: .center) {
                Text(quote.displayAuthor)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Palette.ink.opacity(0.8))
                    .lineLimit(1)
                Spacer()
                WidgetButtons(quote: quote, isFavorite: isFavorite)
            }
        }
        .foregroundStyle(Palette.ink)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct LargeQuoteView: View {
    let quote: Quote
    let isFavorite: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(quote.category.title, systemImage: quote.category.symbol)
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(Palette.ink.opacity(0.85))
                    .widgetAccentable()
                Spacer()
                WidgetButtons(quote: quote, isFavorite: isFavorite)
            }
            Spacer(minLength: 0)
            QuoteMark(size: 28)
            Text(quote.text)
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .lineSpacing(2)
                .minimumScaleFactor(0.5)
                .layoutPriority(1)
            Text("— \(quote.displayAuthor)")
                .font(.headline)
                .foregroundStyle(Palette.ink.opacity(0.85))
            Spacer(minLength: 0)
        }
        .foregroundStyle(Palette.ink)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct WidgetButtons: View {
    let quote: Quote
    let isFavorite: Bool
    var body: some View {
        HStack(spacing: 8) {
            Button(intent: ToggleFavoriteIntent(quoteID: quote.id)) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 30, height: 30)
                    .background(Palette.ink.opacity(0.1), in: .circle)
            }
            .accessibilityLabel(isFavorite ? "Remove from Favorites" : "Add to Favorites")
            Button(intent: NextQuoteIntent()) {
                Image(systemName: "arrow.right")
                    .frame(width: 30, height: 30)
                    .background(Palette.ink.opacity(0.1), in: .circle)
            }
            .accessibilityLabel("Next Quote")
        }
        .font(.system(size: 13, weight: .bold))
        .foregroundStyle(Palette.ink)
        .buttonStyle(.plain)
        .invalidatableContent()
    }
}

private struct RectangularQuoteView: View {
    let quote: Quote
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(quote.text)
                .font(.system(.headline, design: .serif))
                .lineLimit(3)
                .minimumScaleFactor(0.6)
            Text(quote.displayAuthor)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct EmptyQuoteView: View {
    @Environment(\.widgetFamily) private var family
    let source: QuoteSource

    private var message: String {
        source == .favorites ? "Tap ♥ on a quote in the app to see it here." : "Add your own quotes in the app."
    }

    var body: some View {
        if family == .accessoryInline || family == .accessoryRectangular {
            Text(source == .favorites ? "No favorites yet" : "No quotes yet")
        } else {
            VStack(spacing: 8) {
                Image(systemName: source == .favorites ? "heart" : "pencil")
                    .font(.title2.weight(.semibold))
                    .widgetAccentable()
                Text(source == .favorites ? "No Favorites Yet" : "No Quotes Yet")
                    .font(.headline)
                Text(message)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.ink.opacity(0.8))
            }
            .foregroundStyle(Palette.ink)
        }
    }
}

// MARK: - Widget

struct QuotesWidget: Widget {
    let kind = "QuotesWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: QuoteWidgetIntent.self, provider: QuoteProvider()) { entry in
            QuoteWidgetView(entry: entry)
        }
        .configurationDisplayName("Quote")
        .description("A fresh quote on your Home Screen or Lock Screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryInline])
    }
}

@main
struct QuotesWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuotesWidget()
    }
}

#Preview("Small", as: .systemSmall) {
    QuotesWidget()
} timeline: {
    QuoteEntry(date: .now, quote: QuoteLibrary.builtIn[0], source: .all, isFavorite: false)
    QuoteEntry(date: .now, quote: QuoteLibrary.builtIn[20], source: .all, isFavorite: true)
}

#Preview("Medium", as: .systemMedium) {
    QuotesWidget()
} timeline: {
    QuoteEntry(date: .now, quote: QuoteLibrary.builtIn[25], source: .all, isFavorite: true)
}

#Preview("Large", as: .systemLarge) {
    QuotesWidget()
} timeline: {
    QuoteEntry(date: .now, quote: QuoteLibrary.builtIn[34], source: .all, isFavorite: false)
}
