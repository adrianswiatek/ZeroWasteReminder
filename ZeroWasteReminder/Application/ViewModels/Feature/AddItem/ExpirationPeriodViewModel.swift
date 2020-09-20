import Combine

public final class ExpirationPeriodViewModel {
    @Published public var period: String
    @Published public var periodTypeIndex: Int

    public var periodType: AnyPublisher<PeriodType, Never> {
        periodTypeSubject.eraseToAnyPublisher()
    }

    public var isValid: AnyPublisher<Bool, Never> {
        $period.map { [weak self] in self?.periodValidationRules.areValid($0) == true }.eraseToAnyPublisher()
    }

    public var expiration: Expiration {
        guard let period = Int(period) else {
            preconditionFailure("Period cannot be parsed.")
        }
        return .date(.fromPeriod(period, ofType: periodTypeSubject.value))
    }

    private let periodTypeSubject: CurrentValueSubject<PeriodType, Never>

    private let periodValidationRules: ValidationRules
    private var subscriptions: Set<AnyCancellable>

    public init(initialPeriodType: PeriodType) {
        period = ""
        periodTypeIndex = initialPeriodType.index

        periodTypeSubject = .init(initialPeriodType)

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
            .sink { [weak self] in self?.periodTypeSubject.send($0) }
            .store(in: &subscriptions)
    }
}
