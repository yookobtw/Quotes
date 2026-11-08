import SwiftUI

struct LibraryView: View {
    @Environment(QuoteStore.self) private var store
    @State private var search = ""
    @State private var filter: QuoteCategory?
    @State private var showingAdd = false
    @State private var editing: Quote?
    @State private var selection = Set<String>()
    @State private var editMode: EditMode = .inactive

    private var filtered: [Quote] {
        store.allQuotes.filter { quote in
            (filter == nil || quote.category == filter) &&
            (search.isEmpty
                || quote.text.localizedCaseInsensitiveContains(search)
                || quote.author.localizedCaseInsensitiveContains(search))
        }
    }

    private var isSelecting: Bool { editMode.isEditing }

    var body: some View {
        NavigationStack {
            List(selection: $selection) {
                if !isSelecting {
                    Section {
                        CategoryFilterBar(selection: $filter)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section {
                    ForEach(filtered) { quote in
                        NavigationLink(value: quote) {
                            QuoteRow(quote: quote)
                        }
                        .tag(quote.id)
                        .swipeActions(edge: .leading) {
                            FavoriteSwipeButton(quote: quote)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                withAnimation { store.delete(quote) }
                            }
                            Button("Edit", systemImage: "pencil") { editing = quote }
                                .tint(Palette.fog)
                        }
                        .contextMenu {
                            QuoteActions(quote: quote, onEdit: { editing = quote })
                        }
                    }
                } footer: {
                    Text(filtered.count == 1 ? "1 quote" : "\(filtered.count) quotes")
                }
            }
            .environment(\.editMode, $editMode)
            .overlay {
                if filtered.isEmpty {
                    if !search.isEmpty {
                        ContentUnavailableView.search(text: search)
                    } else {
                        ContentUnavailableView {
                            Label("No Quotes", systemImage: "text.quote")
                        } actions: {
                            Button("Add Quote", systemImage: "plus") { showingAdd = true }
                                .buttonStyle(.glassProminent)
                        }
                    }
                }
            }
            .navigationTitle("Library")
            .searchable(text: $search, prompt: "Quotes or authors")
            .navigationDestination(for: Quote.self) { QuoteDetailView(quote: $0) }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(isSelecting ? "Done" : "Select") {
                        withAnimation {
                            editMode = isSelecting ? .inactive : .active
                            selection.removeAll()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Quote", systemImage: "plus") { showingAdd = true }
                        .disabled(isSelecting)
                }
                if isSelecting {
                    ToolbarItem(placement: .bottomBar) {
                        Button(role: .destructive) {
                            let doomed = store.allQuotes.filter { selection.contains($0.id) }
                            withAnimation {
                                store.delete(doomed)
                                selection.removeAll()
                                editMode = .inactive
                            }
                        } label: {
                            Label(selection.isEmpty ? "Delete" : "Delete \(selection.count)", systemImage: "trash")
                                .labelStyle(.titleAndIcon)
                        }
                        .disabled(selection.isEmpty)
                    }
                }
            }
            .toolbarVisibility(isSelecting ? .hidden : .automatic, for: .tabBar)
            .sheet(isPresented: $showingAdd) { AddQuoteView() }
            .sheet(item: $editing) { AddQuoteView(editing: $0) }
        }
    }
}

/// Shared menu items for a quote (context menus and the detail screen).
struct QuoteActions: View {
    @Environment(QuoteStore.self) private var store
    let quote: Quote
    var onEdit: () -> Void
    var onDelete: (() -> Void)? = nil

    var body: some View {
        let isFavorite = store.isFavorite(quote)
        Button(isFavorite ? "Remove from Favorites" : "Add to Favorites",
               systemImage: isFavorite ? "heart.slash" : "heart") {
            store.toggleFavorite(quote)
        }
        Button("Show on Today", systemImage: "quote.bubble") {
            store.spotlight = quote
            store.tab = .today
        }
        ShareLink(item: quote.shareText)
        Divider()
        Button("Edit", systemImage: "pencil", action: onEdit)
        Button("Delete", systemImage: "trash", role: .destructive) {
            withAnimation { store.delete(quote) }
            onDelete?()
        }
    }
}

struct CategoryFilterBar: View {
    @Binding var selection: QuoteCategory?

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                chip("All", symbol: "square.grid.2x2.fill", tint: .accentColor, isOn: selection == nil) {
                    selection = nil
                }
                ForEach(QuoteCategory.allCases) { category in
                    chip(category.title, symbol: category.symbol, tint: category.tint, isOn: selection == category) {
                        selection = selection == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
        .sensoryFeedback(.selection, trigger: selection)
    }

    @ViewBuilder
    private func chip(_ title: String, symbol: String, tint: Color, isOn: Bool, action: @escaping () -> Void) -> some View {
        let label = Label(title, systemImage: symbol).font(.subheadline.weight(.medium))
        if isOn {
            Button(action: action) { label }
                .buttonStyle(.glassProminent)
                .tint(tint)
        } else {
            Button(action: action) { label }
                .buttonStyle(.glass)
        }
    }
}

struct QuoteRow: View {
    @Environment(QuoteStore.self) private var store
    let quote: Quote

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Capsule()
                .fill(Palette.fog)
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 6) {
                Text(quote.text)
                    .font(.system(.body, design: .serif))
                    .lineLimit(3)
                HStack(spacing: 6) {
                    Text(quote.displayAuthor)
                    if quote.isCustom {
                        Image(systemName: "pencil")
                            .accessibilityLabel("Your quote")
                    }
                    Spacer()
                    if store.isFavorite(quote) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(Palette.ink)
                            .accessibilityLabel("Favorite")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct FavoriteSwipeButton: View {
    @Environment(QuoteStore.self) private var store
    let quote: Quote

    var body: some View {
        let isFavorite = store.isFavorite(quote)
        Button(isFavorite ? "Unfavorite" : "Favorite", systemImage: isFavorite ? "heart.slash" : "heart") {
            withAnimation { store.toggleFavorite(quote) }
        }
        .tint(Palette.ink)
    }
}

struct QuoteDetailView: View {
    @Environment(QuoteStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let quote: Quote
    @State private var editing: Quote?

    /// Follows edits (and the copy made when a built-in quote is edited).
    private var current: Quote {
        store.allQuotes.first { $0.id == quote.id } ?? quote
    }

    var body: some View {
        QuoteHeroView(quote: current)
            .navigationTitle(current.category.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarVisibility(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("More", systemImage: "ellipsis") {
                        QuoteActions(quote: current, onEdit: { editing = current }, onDelete: { dismiss() })
                    }
                }
            }
            .sheet(item: $editing) { quote in
                AddQuoteView(editing: quote) { saved in
                    if saved.id != quote.id { dismiss() }
                }
            }
    }
}
