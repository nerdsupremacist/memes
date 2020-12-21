
import Foundation
import SwiftUI

struct CaptionListView: View {
    @ObservedObject
    var deck: Deck

    @State
    private var selected: Int?

    @State
    private var isAdding = false

    @StateObject
    private var droppedImage = DroppedImageViewModel()

    var body: some View {
        VStack {
            VStack {
                if droppedImage.isLoading {
                    Text("Loading Caption...").padding()
                }

                if droppedImage.isDropping {
                    Text("Drop image to add the caption from a Meme").padding()
                }
            }
            .sheet(item: droppedImage.binding(), onDismiss: { droppedImage.clear() }) { droppedText in
                EditCaptionView(text: droppedText) { withAnimation { droppedImage.clear() } } save: { text in
                    deck.captions.insert(Caption(text: text), at: 0)
                    deck.save()
                }
                .frame(width: 400, height: 300)
            }

            List(deck.captions.indices, id: \.self, selection: $selected) { index in
                Text(deck.captions[index].text)
            }
            .sheet(item: $selected, onDismiss: { selected = nil }) { index in
                EditCaptionView(text: deck.captions[index].text) { withAnimation { selected = nil } } save: { text in
                    deck.captions[index].text = text
                    deck.save()
                }
                .frame(width: 400, height: 300)
            }
        }
        .onDrop(of: [.fileURL, .image], delegate: droppedImage)
        .navigationTitle("\(deck.name.capitalized) - Captions (\(deck.captions.count))")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { isAdding = true }) {
                    Image(systemName: "plus")
                }.sheet(isPresented: $isAdding, onDismiss: { isAdding = false }) {
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

extension String: Identifiable {
    public var id: String {
        return self
    }
}

extension Int: Identifiable {
    public var id: Int {
        return self
    }
}
