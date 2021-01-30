
import Foundation
import SwiftUI
import URLImage
import Combine

struct AddSingleMemeURL: View {
    @Debounced
    private var text: String

    let dismiss: () -> Void
    let save: ([URL]) -> Void

    init(_ url: URL? = nil, dismiss: @escaping () -> Void, save: @escaping ([URL]) -> Void) {
        self._text = Debounced(wrappedValue: url?.absoluteString ?? "", delay: 0.3)
        self.dismiss = dismiss
        self.save = save
    }

    var body: some View {
        VStack {
            TextField("URL", text: $text)

            if let url = URL(string: text) {
                URLImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                }
            } else {
                Image("")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
            }

            HStack {
                Spacer()

                Button("Cancel") { dismiss() }
                if let url = URL(string: text) {
                    Button("Save") {
                        save([url])
                        dismiss()
                    }
                }
            }
        }
        .padding()
    }
}

@propertyWrapper
public struct Debounced<T: Hashable>: DynamicProperty {
    @StateObject
    private var model: DebouncedModel<T>

    public var wrappedValue: T {
        get {
            return model.value
        }
        nonmutating set {
            model.subject.send(newValue)
        }
    }

    public var projectedValue: Binding<T> {
        return Binding(get: { return model.latestValue },
                       set: { newValue in model.subject.send(newValue) })
    }

    public init(wrappedValue: T, delay: Double) {
        self._model = StateObject(wrappedValue: DebouncedModel(wrappedValue: wrappedValue, delay: delay))
    }
}

private class DebouncedModel<T>: ObservableObject {
    @Published
    private(set) var value: T
    private(set) var latestValue: T

    let subject = PassthroughSubject<T, Never>()
    private var disposeBag: Set<AnyCancellable> = []

    public init(wrappedValue: T, delay: Double) {
        self.value = wrappedValue
        self.latestValue = wrappedValue

        subject
            .sink { [unowned self] latestValue in
                self.latestValue = latestValue
            }
            .store(in: &disposeBag)

        subject
            .debounce(for: .seconds(delay), scheduler: RunLoop.main)
            .sink { [unowned self] value in
                self.value = value
            }
            .store(in: &disposeBag)
    }
}
