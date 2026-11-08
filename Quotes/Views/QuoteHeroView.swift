import SwiftUI

/// Full-bleed gradient page showing one quote — used by Today and the quote detail screen.
struct QuoteHeroView: View {
    @Environment(QuoteStore.self) private var store
    let quote: Quote
    var nextChange: Date? = nil
    var onNext: (() -> Void)?
    var onPrevious: (() -> Void)?

    var body: some View {
        ZStack {
            Rectangle()
                .fill(quote.category.gradient)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "quote.closing")
                        .font(.system(size: 200, weight: .black))
                        .foregroundStyle(Palette.ink.opacity(0.04))
                        .offset(x: 40, y: 170)
                }
                .ignoresSafeArea()
                .id(quote.category)
                .transition(.opacity)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    CategoryPill(category: quote.category)
                    Spacer()
                    if onNext != nil {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(Date.now.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                                .font(.subheadline.weight(.semibold))
                            if let nextChange {
                                Label {
                                    Text(nextChange, style: .relative)
                                        .monospacedDigit()
                                } icon: {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                }
                                .font(.caption)
                                .labelStyle(.titleAndIcon)
                                .accessibilityLabel("Next quote in")
                            }
                        }
                        .foregroundStyle(Palette.ink.opacity(0.75))
                    }
                }
                Spacer(minLength: 24)
                quoteText
                    .id(quote.id)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(y: 16)),
                        removal: .opacity
                    ))
                Spacer(minLength: 24)
                controls
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
        .animation(.smooth(duration: 0.5), value: quote.id)
        .contentShape(Rectangle())
        .gesture(swipe)
        .sensoryFeedback(.selection, trigger: quote.id)
    }

    private var quoteText: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image(systemName: "quote.opening")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Palette.ink.opacity(0.55))
            Text(quote.text)
                .font(.system(size: 34, weight: .semibold, design: .serif))
                .lineSpacing(4)
                .minimumScaleFactor(0.5)
                .foregroundStyle(Palette.ink)
            Text("— \(quote.displayAuthor)")
                .font(.title3.weight(.medium))
                .foregroundStyle(Palette.ink.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var controls: some View {
        let favorite = store.isFavorite(quote)
        return GlassEffectContainer(spacing: 16) {
            HStack(spacing: 16) {
                Button {
                    store.toggleFavorite(quote)
                } label: {
                    Image(systemName: favorite ? "heart.fill" : "heart")
                        .contentTransition(.symbolEffect(.replace))
                        .foregroundStyle(Palette.ink)
                        .frame(width: 28, height: 28)
                }
                .accessibilityLabel(favorite ? "Remove from Favorites" : "Add to Favorites")
                .sensoryFeedback(.impact(weight: .light), trigger: favorite)

                ShareLink(item: quote.shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Palette.ink)
                        .frame(width: 28, height: 28)
                }

                Spacer()

                if let onNext {
                    Button(action: onNext) {
                        Label("Next", systemImage: "arrow.right")
                            .font(.headline)
                            .foregroundStyle(Palette.ink)
                            .padding(.horizontal, 6)
                            .frame(height: 28)
                    }
                }
            }
            .font(.title3)
            .buttonStyle(.glass)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
        }
    }

    private var swipe: some Gesture {
        DragGesture(minimumDistance: 30).onEnded { value in
            if value.translation.width < -60 { onNext?() }
            else if value.translation.width > 60 { onPrevious?() }
        }
    }
}

struct CategoryPill: View {
    let category: QuoteCategory

    var body: some View {
        Label(category.title, systemImage: category.symbol)
            .font(.footnote.weight(.semibold))
            .textCase(.uppercase)
            .tracking(0.8)
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .glassEffect(.regular, in: .capsule)
    }
}
