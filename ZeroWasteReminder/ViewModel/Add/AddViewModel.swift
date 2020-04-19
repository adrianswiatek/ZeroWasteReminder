import Combine

public final class AddViewModel {
    @Published public var itemName: String
    @Published public var expirationTypeIndex: Int

    public let expirationDateViewModel: ExpirationDateViewModel
    public let expirationPeriodViewModel: ExpirationPeriodViewModel

    public var expirationType: AnyPublisher<ExpirationType, Never> {
        expirationTypeSubject.eraseToAnyPublisher()
    }

    public var canSaveItem: AnyPublisher<Bool, Never> {
        canSaveItemSubject.eraseToAnyPublisher()
    }

    public var isExpirationDateVisible: Bool {
        expirationTypeIndex == ExpirationType.date.index
    }

    public var isExpirationPeriodVisible: Bool {
        expirationTypeIndex == ExpirationType.period.index
    }

    private let expirationTypeSubject: CurrentValueSubject<ExpirationType, Never>
    private let canSaveItemSubject: CurrentValueSubject<Bool, Never>

    private var subscriptions: Set<AnyCancellable>

    public init() {
        itemName = ""

        expirationTypeIndex = ExpirationType.none.index

        expirationDateViewModel = .init(.init())
        expirationPeriodViewModel = .init(.day)

        expirationTypeSubject = .init(ExpirationType.none)
        canSaveItemSubject = .init(false)

        subscriptions = []

        bind()
    }

    public func saveItem() -> Future<Void, Never> {
        .init { $0(.success(())) }
    }

    private func bind() {
        expirationType.combineLatest(
            $itemName.map { !$0.isEmpty },
            expirationDateViewModel.isValid,
            expirationPeriodViewModel.isValid
        ) {
            switch $0 {
            case .none where $1:
                return true
            case .date where $2 && $1:
                return true
            case .period where $3 && $1:
                return true
            default:
                return false
            }
        }
        .subscribe(canSaveItemSubject)
        .store(in: &subscriptions)

        $expirationTypeIndex
            .map { ExpirationType.fromIndex($0) }
            .subscribe(expirationTypeSubject)
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
        case .date: return expirationDateViewModel.expiration
        case .period: return expirationPeriodViewModel.expiration
        }
    }
}
