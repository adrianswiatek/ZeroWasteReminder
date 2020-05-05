import Combine
import Foundation

public final class EditViewModel {
    @Published var name: String

    public var expirationDate: AnyPublisher<String, Never> {
        expirationDateSubject
            .map { [weak self] in self?.formattedDate($0) ?? "[Not defined]" }
            .eraseToAnyPublisher()
    }

    public var isExpirationDateVisible: AnyPublisher<Bool, Never>  {
        isExpirationDateVisibleSubject.eraseToAnyPublisher()
    }

    private let expirationDateSubject: CurrentValueSubject<Date?, Never>
    private let isExpirationDateVisibleSubject: CurrentValueSubject<Bool, Never>

    private let originalItem: Item
    private let dateFormatter: DateFormatter

    private var subscriptions: Set<AnyCancellable>

    public init(item: Item) {
        originalItem = item
        dateFormatter = .fullDateFormatter

        name = item.name

        if case .date(let date) = item.expiration {
            expirationDateSubject = .init(date)
        } else {
            expirationDateSubject = .init(nil)
        }

        isExpirationDateVisibleSubject = .init(false)

        subscriptions = []
    }

    public func toggleExpirationDatePicker() {
        isExpirationDateVisibleSubject.value.toggle()
    }

    public func setExpirationDate(_ date: Date?) {
        expirationDateSubject.value = date
    }

    private func formattedDate(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        return dateFormatter.string(from: date)
    }
}
