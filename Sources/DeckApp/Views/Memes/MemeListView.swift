
import Foundation
import SwiftUI
import URLImage

struct MemeListView: View {
    @State
    private var isAdding = false

    @ObservedObject
    var deck: Deck

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 50, maximum: 200)),
                        GridItem(.flexible(minimum: 50, maximum: 200)),
                        GridItem(.flexible(minimum: 50, maximum: 200))],
                    alignment: .center,
                    spacing: 16
                ) {
                    ForEach(deck.memes, id: \.id) { meme in
                        URLImage(url: meme.image) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipped()
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("\(deck.name.capitalized) - Memes (\(deck.memes.count))")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { isAdding = true }) {
                    Image(systemName: "plus")
                }.sheet(isPresented: $isAdding, onDismiss: { isAdding = false }) {
                    AddMemesModal { isAdding = false } save: { images in
                        deck.memes.insert(contentsOf: images.map { Meme(image: $0) }, at: 0)
                        deck.save()
                    }
                    .frame(minWidth: 800, minHeight: 400)
                }
            }
        }
    }
}

extension URL: Identifiable {
    public var id: URL {
        return self
    }
}
