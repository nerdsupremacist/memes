
import Foundation
import SwiftUI
import URLImage

struct AddMemesFromSource: View {
    @StateObject
    private var viewModel: ViewModel
    private let dismiss: () -> Void
    private let save: ([URL]) -> Void

    @State
    var selected: Set<Int> = []

    init(_ source: MemeImageSource.Type, dismiss: @escaping () -> Void, save: @escaping ([URL]) -> Void) {
        self._viewModel = StateObject(wrappedValue: ViewModel(source))
        self.dismiss = dismiss
        self.save = save
    }

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
                    ForEach(viewModel.images.indices, id: \.self) { index in
                        ZStack {
                            URLImage(url: viewModel.images[index]) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipped()
                            }
                            .onAppear {
                                if index == viewModel.images.count - 1 {
                                    viewModel.loadMore()
                                }
                            }

                            if selected.contains(index) {
                                Color.accentColor.opacity(0.3)

                                Image(systemName: "checkmark")
                                    .resizable()
                                    .foregroundColor(.primary)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        .onTapGesture {
                            if selected.contains(index) {
                                selected.subtract([index])
                            } else {
                                selected.formUnion([index])
                            }
                        }
                    }
                }
                .padding(16)
            }
            .onAppear {
                if viewModel.images.isEmpty {
                    viewModel.loadMore()
                }
            }

            HStack {
                Spacer()

                Button("Cancel") { dismiss() }

                if !selected.isEmpty {
                    Button("Save") {
                        save(selected.map { viewModel.images[$0] })
                        dismiss()
                    }
                }
            }
        }
        .padding([.bottom, .horizontal])
    }
}

extension AddMemesFromSource {

    class ViewModel: ObservableObject {
        @Published
        var images: [URL] = []

        @Published
        var isLoading = false

        @Published
        var error: Error?

        private let source: MemeImageSource

        init(_ source: MemeImageSource.Type) {
            self.source = source.init()
        }

        func loadMore() {
            guard !isLoading, source.hasMore else { return }
            error = nil
            isLoading = true
            source.loadMore { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let urls):
                        self.images.append(contentsOf: urls)
                    case .failure(let error):
                        self.error = error
                    }
                    self.isLoading = false
                }
            }
        }
    }

}
