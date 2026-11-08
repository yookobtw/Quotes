import SwiftUI

/// Adds a new quote, or edits an existing one when `editing` is set.
struct AddQuoteView: View {
    @Environment(QuoteStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var editing: Quote?
    var onSave: ((Quote) -> Void)?

    @State private var text: String
    @State private var author: String
    @State private var category: QuoteCategory
    @FocusState private var textFocused: Bool

    init(editing: Quote? = nil, onSave: ((Quote) -> Void)? = nil) {
        self.editing = editing
        self.onSave = onSave
        _text = State(initialValue: editing?.text ?? "")
        _author = State(initialValue: editing?.author ?? "")
        _category = State(initialValue: editing?.category ?? .wisdom)
    }

    private var trimmedText: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedAuthor: String { author.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Quote", text: $text, axis: .vertical)
                        .font(.system(.body, design: .serif))
                        .lineLimit(3...8)
                        .focused($textFocused)
                    TextField("Author", text: $author)
                        .textInputAutocapitalization(.words)
                } footer: {
                    if let editing, !editing.isCustom {
                        Text("Editing a built-in quote saves it as your own.")
                    }
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(QuoteCategory.allCases) { category in
                            Label(category.title, systemImage: category.symbol).tag(category)
                        }
                    }
                }

                Section("Widget Preview") {
                    WidgetPreviewCard(quote: Quote(
                        text: trimmedText.isEmpty ? "Your words, on your Home Screen." : trimmedText,
                        author: trimmedAuthor,
                        category: category
                    ))
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(editing == nil ? "New Quote" : "Edit Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editing == nil ? "Add" : "Save", systemImage: "checkmark", role: .confirm) {
                        save()
                        dismiss()
                    }
                    .disabled(trimmedText.isEmpty)
                }
            }
            .onAppear { if editing == nil { textFocused = true } }
        }
    }

    private func save() {
        if var quote = editing {
            quote.text = trimmedText
            quote.author = trimmedAuthor
            quote.category = category
            onSave?(store.update(quote))
        } else {
            let quote = Quote(text: trimmedText, author: trimmedAuthor, category: category, isCustom: true)
            store.add(quote)
            onSave?(quote)
        }
    }
}

/// Mimics the medium widget so people can see how their quote will look.
struct WidgetPreviewCard: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "quote.opening")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Palette.ink.opacity(0.6))
            Text(quote.text)
                .font(.system(size: 19, weight: .semibold, design: .serif))
                .lineLimit(4)
                .minimumScaleFactor(0.6)
            Spacer(minLength: 0)
            Text(quote.displayAuthor)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Palette.ink.opacity(0.8))
        }
        .foregroundStyle(Palette.ink)
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 155, alignment: .topLeading)
        .background(quote.category.gradient, in: .rect(cornerRadius: 24, style: .continuous))
        .animation(.smooth, value: quote.category)
    }
}
