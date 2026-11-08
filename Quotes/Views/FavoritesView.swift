import SwiftUI

struct FavoritesView: View {
    @Environment(QuoteStore.self) private var store

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.favorites) { quote in
                    NavigationLink(value: quote) {
                        QuoteRow(quote: quote)
                    }
                    .swipeActions {
                        Button("Remove", systemImage: "heart.slash", role: .destructive) {
                            withAnimation { store.toggleFavorite(quote) }
                        }
                    }
                }
            }
            .overlay {
                if store.favorites.isEmpty {
                    ContentUnavailableView {
                        Label("No Favorites Yet", systemImage: "heart")
                    } description: {
                        Text("Tap the heart on any quote to save it here. Set your widget to Favorites to see only these.")
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationDestination(for: Quote.self) { QuoteDetailView(quote: $0) }
        }
    }
}
