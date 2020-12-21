
import Foundation
import SwiftUI

struct CaptionListView: View {
    @ObservedObject
    var deck: Deck

    @State
    private var selected: Int?

    @State
    private var isAdding = false

    var body: some View {
        List(deck.captions.indices, id: \.self, selection: $selected) { index in
            Text(deck.captions[index].text)
        }
        .navigationTitle("\(deck.name.capitalized) - Captions (\(deck.captions.count))")
        .sheet(item: $selected, onDismiss: { selected = nil }) { index in
            EditCaptionView(text: deck.captions[index].text) { withAnimation { selected = nil } } save: { text in
                deck.captions[index].text = text
                deck.save()
            }
            .frame(width: 400, height: 300)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { isAdding = true }) {
                    Image(systemName: "plus")
                }.sheet(isPresented: $isAdding, onDismiss: { selected = nil }) {
                    EditCaptionView(text: "") { withAnimation { isAdding = false } } save: { text in
                        deck.captions.insert(Caption(text: text), at: 0)
                        deck.save()
                    }
                    .frame(width: 400, height: 300)
                }
            }
        }
    }
}

extension Int: Identifiable {
    public var id: Int {
        return self
    }
}
