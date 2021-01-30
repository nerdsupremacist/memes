
import SwiftUI
import Combine
import Vision
import UniformTypeIdentifiers

class DroppedImageViewModel: ObservableObject, DropDelegate {
    @Published
    private(set) var text: String?

    @Published
    private(set) var isLoading = false

    @Published
    private(set) var isDropping = false

    func clear() {
        text = nil
    }

    func binding() -> Binding<String?> {
        return Binding(
            get: { self.text },
            set: { self.text = $0 }
        )
    }

    func binding(using otherBinding: Binding<String>) -> Binding<String> {
        return Binding(
            get: { self.text ?? otherBinding.wrappedValue },
            set: { self.text = nil; otherBinding.wrappedValue = $0 }
        )
    }

    func dropEntered(info: DropInfo) {
        isDropping = true
    }

    func dropExited(info: DropInfo) {
        isDropping = false
    }

    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: [.image, .png, .jpeg, .rawImage, .webP, .aiff, .fileURL]).first {
            start(with: item)
            return true
        }
        return true
    }

    private func start(with item: NSItemProvider) {
        guard !isLoading else { return }

        item.loadItem(for: [.image, .png, .jpeg, .rawImage, .webP, .aiff, .fileURL]) { result, type in
            guard case .success(let data) = result else { return }
            switch type {
            case .url, .fileURL:
                guard let url = URL(dataRepresentation: data, relativeTo: nil),
                      let image = NSImage(contentsOf: url) else { return }

                self.start(with: image)

            case .image, .png, .jpeg, .rawImage, .webP, .aiff:
                guard let image = NSImage(data: data) else { return }
                self.start(with: image)

            default:
                fatalError()
            }
        }
    }

    private func start(with nsImage: NSImage) {
        guard let image = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        DispatchQueue.main.async {
            self.isLoading = true
        }
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                fatalError("Received invalid observations")
            }

            DispatchQueue.main.async {
                self.isLoading = false
                self.text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
            }
        }
        DispatchQueue.global(qos: .background).async {
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            try! handler.perform([request])
        }
    }
}

extension NSItemProvider {

    func loadItem(for types: [UTType], block: @escaping (Result<Data, Error>, UTType) -> Void) {
        for type in types {
            if hasItemConformingToTypeIdentifier(type.identifier) {
                loadItem(forTypeIdentifier: type.identifier, options: nil) { data, error in
                    switch (data, error) {
                    case (let data as Data, .none):
                        block(.success(data), type)
                    case (_, .some(let error)):
                        block(.failure(error), type)
                    default:
                        fatalError()
                    }
                }
                return
            }
        }
    }

}
