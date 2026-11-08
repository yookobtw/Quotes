import SwiftUI

struct SettingsView: View {
    @Environment(QuoteStore.self) private var store
    @State private var confirmingRestore = false

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            Form {
                Section {
                    Picker("Appearance", selection: $store.appearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Label(mode.title, systemImage: mode.symbol).tag(mode)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Automatic follows your iPhone’s Light and Dark Mode. Widgets always follow the system setting.")
                }

                Section {
                    Picker("New Quote", selection: Binding(
                        get: { store.rotation },
                        set: { store.setRotation($0) }
                    )) {
                        ForEach(RefreshFrequency.appChoices) { frequency in
                            Text(frequency.title).tag(frequency)
                        }
                    }
                    .pickerStyle(.menu)

                    LabeledContent("Next Change") {
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            Text(store.nextChange(after: context.date), style: .relative)
                                .monospacedDigit()
                        }
                    }
                } header: {
                    Text("Quote Rotation")
                } footer: {
                    Text("Today and any widget set to “Same as App” switch to a new quote on this schedule. You can still tap Next anytime.")
                }

                Section {
                    LabeledContent("Quotes", value: "\(store.allQuotes.count)")
                    LabeledContent("Your Quotes", value: "\(store.customQuotes.count)")
                    LabeledContent("Favorites", value: "\(store.favoriteIDs.count)")
                    Button("Restore Deleted Quotes", systemImage: "arrow.uturn.backward") {
                        confirmingRestore = true
                    }
                    .disabled(store.deletedCount == 0)
                    .confirmationDialog(
                        "Restore \(store.deletedCount) built-in quotes?",
                        isPresented: $confirmingRestore,
                        titleVisibility: .visible
                    ) {
                        Button("Restore") { withAnimation { store.restoreDeleted() } }
                    }
                } header: {
                    Text("Library")
                } footer: {
                    Text("Deleted built-in quotes can be brought back here. Quotes you wrote are gone for good once deleted.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
