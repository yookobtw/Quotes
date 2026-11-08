import SwiftUI

struct TodayView: View {
    @Environment(QuoteStore.self) private var store
    @State private var showingWidgetHelp = false

    var body: some View {
        NavigationStack {
            // Re-renders exactly when the current quote's time slot ends.
            TimelineView(RotationSchedule(store: store)) { context in
                QuoteHeroView(
                    quote: store.quote(at: context.date),
                    nextChange: store.spotlight == nil ? store.nextChange(after: context.date) : nil,
                    onNext: { store.step(1) },
                    onPrevious: { store.step(-1) }
                )
            }
            .navigationTitle("Today")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Widget", systemImage: "square.grid.2x2") {
                        showingWidgetHelp = true
                    }
                }
            }
            .sheet(isPresented: $showingWidgetHelp) {
                WidgetHelpView()
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

/// Fires at every rotation boundary (e.g. on the hour) so Today changes by itself.
@MainActor
struct RotationSchedule: TimelineSchedule {
    let interval: TimeInterval
    let start: Date

    init(store: QuoteStore) {
        interval = store.rotation.interval
        start = QuotePicker.start(ofSlot: QuotePicker.slot(for: .now, interval: interval), interval: interval)
    }

    nonisolated func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(from: start, by: interval).entries(from: startDate, mode: mode)
    }
}

struct WidgetHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    step("hand.tap.fill", "Touch and hold an empty area of your Home Screen until the apps jiggle.")
                    step("plus.circle.fill", "Tap Edit in the top corner, then Add Widget.")
                    step("magnifyingglass", "Search for Quotes, pick a size and tap Add Widget.")
                    step("slider.horizontal.3", "Touch and hold the widget, then choose Edit Widget to pick Favorites, a category, or how often it changes.")
                } header: {
                    Text("Home Screen")
                }
                Section {
                    step("lock.fill", "Touch and hold your Lock Screen, tap Customize, then Lock Screen.")
                    step("rectangle.badge.plus", "Tap the widget area below the clock and add Quotes.")
                } header: {
                    Text("Lock Screen")
                } footer: {
                    Text("Tap ♥ or → on a medium or large widget to favorite a quote or skip to the next one.")
                }
            }
            .navigationTitle("Add the Widget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark", role: .confirm) { dismiss() }
                }
            }
        }
    }

    private func step(_ symbol: String, _ text: String) -> some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: symbol).foregroundStyle(.tint)
        }
        .padding(.vertical, 2)
    }
}
