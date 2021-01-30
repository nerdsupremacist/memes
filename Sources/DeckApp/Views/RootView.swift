
import Foundation
import SwiftUI

struct RootView: View {
    let decks: [Deck]

    var body: some View {
        NavigationView {
            List {
                ForEach(decks, id: \.name) { deck in
                    Section(header: Text(deck.name.capitalized)) {
                        NavigationLink(destination: MemeListView(deck: deck)) {
                            Label("Memes", systemImage: "camera.fill")
                        }

                        NavigationLink(destination: CaptionListView(deck: deck)) {
                            Label("Captions", systemImage: "doc.text")
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200, idealWidth: 200, maxWidth: 200, maxHeight: .infinity)
        }
    }
}
