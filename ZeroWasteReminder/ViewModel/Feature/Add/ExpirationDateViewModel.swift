import Combine
import Foundation

public final class ExpirationDateViewModel {
    @Published public var date: Date

    public var formattedDate: AnyPublisher<String, Never> {
        formattedDateSubject.eraseToAnyPublisher()
    }

    public var isDatePickerVisible: AnyPublisher<Bool, Never> {
        isDatePickerVisibleSubject.eraseToAnyPublisher()
    }

    public var isValid: AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    public var expiration: Expiration {
        .date(date)
    }

    private let isDatePickerVisibleSubject: CurrentValueSubject<Bool, Never>
    private let formattedDateSubject: CurrentValueSubject<String, Never>

    private var subscriptions: Set<AnyCancellable>

    private static let dateFormatter: DateFormatter = .fullDateFormatter

    public init(_ initialDate: Date) {
        date = initialDate

        isDatePickerVisibleSubject = .init(false)
        formattedDateSubject = .init(Self.dateFormatter.string(from: initialDate))

        subscriptions = []

        bind()
    }

    public func toggleDatePicker() {
        isDatePickerVisibleSubject.value.toggle()
    }

    public func hideDatePicker() {
        isDatePickerVisibleSubject.value = false
    }

    private func bind() {
        $date
            .map { Self.dateFormatter.string(from: $0) }
            .sink { [weak self] in self?.formattedDateSubject.send($0) }
            .store(in: &subscriptions)
    }
}
