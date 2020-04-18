import Combine

public final class ExpirationPeriodViewModel {
    @Published public var period: String
    @Published public var periodTypeIndex: Int

    public var periodType: AnyPublisher<PeriodType, Never> {
        periodTypeSubject.eraseToAnyPublisher()
    }

    public var isValid: AnyPublisher<Bool, Never> {
        isValidSubject.eraseToAnyPublisher()
    }

    public var expiration: Expiration {
        guard let period = Int(period) else {
            preconditionFailure("Period cannot be parsed.")
        }
        return .date(.fromPeriod(period, ofType: periodTypeSubject.value))
    }

    private let periodTypeSubject: CurrentValueSubject<PeriodType, Never>
    private let isValidSubject: CurrentValueSubject<Bool, Never>

    private let periodValidationRules: ValidationRules
    private var subscriptions: Set<AnyCancellable>

    public init(_ initialPeriodType: PeriodType) {
        period = ""
        periodTypeIndex = initialPeriodType.index

        periodTypeSubject = .init(initialPeriodType)
        isValidSubject = .init(false)

        periodValidationRules = .init(.isNotEmpty, .doesNotStartFromZero, .hasMaxCount(3), .isPositiveNumber)
        subscriptions = []

        bind()
    }

    public func canUpdate(period periodText: String) -> Bool {
        periodText.isEmpty || periodValidationRules.areValid(periodText)
    }

    private func bind() {
        $periodTypeIndex
            .map { PeriodType.fromIndex($0) }
            .subscribe(periodTypeSubject)
            .store(in: &subscriptions)

        $period
            .map { [weak self] in self?.periodValidationRules.areValid($0) == true }
            .sink { [weak self] in self?.isValidSubject.send($0) }
            .store(in: &subscriptions)
    }
}
