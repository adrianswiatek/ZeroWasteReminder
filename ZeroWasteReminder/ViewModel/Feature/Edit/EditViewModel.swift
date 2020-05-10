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

    public var state: AnyPublisher<RemainingState, Never> {
        expirationDateSubject
            .map { $0 != nil ? Expiration.date($0!) : .none }
            .map { RemainingState(expiration: $0) }
            .eraseToAnyPublisher()
    }

    public var canSave: AnyPublisher<Bool, Never> {
        canSaveSubject.eraseToAnyPublisher()
    }

    private let expirationDateSubject: CurrentValueSubject<Date?, Never>
    private let isExpirationDateVisibleSubject: CurrentValueSubject<Bool, Never>
    private let canSaveSubject: CurrentValueSubject<Bool, Never>
    private let originalItemSubject: CurrentValueSubject<Item, Never>

    private let dateFormatter: DateFormatter
    private var subscriptions: Set<AnyCancellable>

    public init(item: Item) {
        originalItemSubject = .init(item)
        dateFormatter = .fullDateFormatter

        name = item.name

        if case .date(let date) = item.expiration {
            expirationDateSubject = .init(date)
        } else {
            expirationDateSubject = .init(nil)
        }

        isExpirationDateVisibleSubject = .init(false)
        canSaveSubject = .init(false)

        subscriptions = []

        bind()
    }

    public func toggleExpirationDatePicker() {
        isExpirationDateVisibleSubject.value.toggle()
    }

    public func setExpirationDate(_ date: Date?) {
        expirationDateSubject.value = date
    }

    public func save() -> Future<Item, Never> {
        Future<Item, Never> { [weak self] promise in
            guard
                let self = self,
                let item = self.tryCreateItem(self.name, self.expirationDateSubject.value)
            else { preconditionFailure("Unable to create item.") }

            self.originalItemSubject.value = item
            promise(.success(item))
        }
    }

    private func bind() {
        Publishers.CombineLatest3(originalItemSubject, $name, expirationDateSubject)
            .map { !$1.isEmpty && $0 != $0.withName($1).withExpirationDate($2) }
            .subscribe(canSaveSubject)
            .store(in: &subscriptions)
    }

    private func formattedDate(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        return dateFormatter.string(from: date)
    }

    private func tryCreateItem(_ name: String, _ expirationDate: Date?) -> Item? {
        guard !name.isEmpty else { return nil }

        let id = originalItemSubject.value.id

        if let expirationDate = expirationDate {
            return Item(id: id, name: name, expiration: .date(expirationDate))
        }

        return Item(id: id, name: name, expiration: .none)
    }
}
