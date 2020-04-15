import Combine
import Foundation

public final class AddViewModel {
    @Published public var itemName: String

    @Published public var expirationIndex: Int

    @Published public var year: String
    @Published public var month: String
    @Published public var day: String

    @Published public var period: String
    @Published public var periodTypeIndex: Int

    public var expirationType: AnyPublisher<ExpirationType, Never> {
        expirationTypeSubject.eraseToAnyPublisher()
    }

    public var periodType: AnyPublisher<PeriodType, Never> {
        periodTypeSubject.eraseToAnyPublisher()
    }

    public var isExpirationDateVisible: Bool {
        expirationIndex == ExpirationType.date.index
    }

    public var isExpirationPeriodVisible: Bool {
        expirationIndex == ExpirationType.period.index
    }

    private let expirationTypeSubject: CurrentValueSubject<ExpirationType, Never>
    private let periodTypeSubject: CurrentValueSubject<PeriodType, Never>

    private var subscriptions: Set<AnyCancellable>

    public init() {
        self.itemName = ""

        self.expirationIndex = ExpirationType.none.index

        self.year = ""
        self.month = ""
        self.day = ""

        self.period = ""
        self.periodTypeIndex = PeriodType.day.index

        self.expirationTypeSubject = .init(ExpirationType.none)
        self.periodTypeSubject = .init(PeriodType.day)

        self.subscriptions = []

        self.bind()
    }

    public func saveItem() -> Future<Void, Never> {
        print(createItem() ?? "[n/a]")
        return .init { $0(.success(())) }
    }

    private func bind() {
        $expirationIndex
            .map { ExpirationType.fromIndex($0) }
            .subscribe(expirationTypeSubject)
            .store(in: &subscriptions)

        $periodTypeIndex
            .map { PeriodType.fromIndex($0) }
            .subscribe(periodTypeSubject)
            .store(in: &subscriptions)
    }

    private func createItem() -> Item? {
        guard !itemName.isEmpty, let expiration = expirationForType(expirationTypeSubject.value) else {
            return nil
        }

        return Item(name: itemName, expiration: expiration)
    }

    private func expirationForType(_ expirationType: ExpirationType) -> Expiration? {
        switch expirationType {
        case .none: return Expiration.none
        case .date: return tryCreateExpirationFromDate()
        case .period: return tryCreateExpirationFromPeriod()
        }
    }

    private func tryCreateExpirationFromDate() -> Expiration? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = dateFormatter.date(from: "\(year)-\(month)-\(day)") else {
            return nil
        }

        return .date(date)
    }

    private func tryCreateExpirationFromPeriod() -> Expiration? {
        guard let period = Int(period) else { return nil }
        return .fromPeriod(period, ofType: .fromIndex(periodTypeIndex))
    }
}
