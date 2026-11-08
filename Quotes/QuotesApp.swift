import SwiftUI

@main
struct QuotesApp: App {
    @State private var store = QuoteStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(store.appearance.colorScheme)
                .onOpenURL { store.handle($0) }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { store.reload() }
                }
        }
    }
}

struct RootView: View {
    @Environment(QuoteStore.self) private var store

    var body: some View {
        @Bindable var store = store
        TabView(selection: $store.tab) {
            Tab("Today", systemImage: "quote.bubble.fill", value: AppTab.today) {
                TodayView()
            }
            Tab("Library", systemImage: "books.vertical.fill", value: AppTab.library) {
                LibraryView()
            }
            Tab("Favorites", systemImage: "heart.fill", value: AppTab.favorites) {
                FavoritesView()
            }
            Tab("Settings", systemImage: "gearshape.fill", value: AppTab.settings) {
                SettingsView()
            }
        }
    }
}
