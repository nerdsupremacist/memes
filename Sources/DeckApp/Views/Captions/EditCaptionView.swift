
import Foundation
import SwiftUI

struct EditCaptionView: View {
    @StateObject
    var viewModel = DroppedImageViewModel()

    @State
    var text: String

    var dismiss: () -> Void
    var save: (String) -> Void

    var body: some View {
        if viewModel.isLoading {
            Text("Loading...").padding()
        } else {
            VStack {
                if viewModel.isDropping {
                    Spacer()
                    Text("Drop Image")
                } else {
                    TextEditor(text: viewModel.binding(using: $text))
                }

                Spacer()

                HStack {
                    Spacer()

                    Button("Cancel") { dismiss() }
                    Button("Save") {
                        save(text)
                        dismiss()
                    }
                }
            }
            .padding()
            .onDrop(of: [.fileURL, .image, .rawImage], delegate: viewModel)
        }
    }
}
