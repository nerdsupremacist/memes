
import Foundation
import SwiftUI

struct AddMemesModal: View {
    let dismiss: () -> Void
    let save: ([URL]) -> Void

    var body: some View {
        TabView {
            AddSingleMemeURL(dismiss: dismiss, save: save).tabItem { Text("URL") }
            AddMemesFromSource(MemeMakerSource.self, dismiss: dismiss, save: save).tabItem { Text("Meme Maker") }
            AddMemesFromSource(ImgflipSource.self, dismiss: dismiss, save: save).tabItem { Text("Imgflip") }
        }
        .padding(.top)
    }
}
