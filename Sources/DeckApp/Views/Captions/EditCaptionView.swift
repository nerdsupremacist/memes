
import Foundation
import SwiftUI
import Vision
import UniformTypeIdentifiers

struct EditCaptionView: View, DropDelegate {
    @State
    var text: String

    @State
    var isLoading = false

    @State
    var isDropping = false

    var dismiss: () -> Void
    var save: (String) -> Void

    var body: some View {
        if isLoading {
            Text("Loading...").padding()
        } else {
            VStack {
                if isDropping {
                    Spacer()
                    Text("Drop Image")
                } else {
                    TextEditor(text: $text)
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
            .onDrop(of: [.fileURL, .image, .rawImage], delegate: self)
        }
    }

    func dropEntered(info: DropInfo) {
        isDropping = true
    }

    func dropExited(info: DropInfo) {
        isDropping = false
    }

    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: [.fileURL]).first {
            item.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, error in
                guard let data = data as? Data, let url = URL(dataRepresentation: data, relativeTo: nil), let image = NSImage(contentsOf: url) else { return }
                start(with: image)
            }

            return true
        }
        return true
    }

    private func start(with nsImage: NSImage) {
        guard let image = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        isLoading = true
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                fatalError("Received invalid observations")
            }

            DispatchQueue.main.async {
                isLoading = false
                self.text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
            }
        }
        DispatchQueue.global(qos: .background).async {
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            try! handler.perform([request])
        }
    }
}
