import CloudKit
import Combine

public final class CloudKitAccountService: AccountService {
    public var isUserEligible: AnyPublisher<Bool, Never> {
        isUserEligibleSubject.share().eraseToAnyPublisher()
    }

    private let container: CKContainer
    private let notificationCenter: NotificationCenter

    private let isUserEligibleSubject: CurrentValueSubject<Bool, Never>
    private var subscriptions: Set<AnyCancellable>

    public init(configuration: CloudKitConfiguration, notificationCenter: NotificationCenter) {
        self.container = configuration.container
        self.notificationCenter = notificationCenter

        self.isUserEligibleSubject = .init(false)
        self.subscriptions = []

        self.bind()
    }

    public func refreshUserEligibility() {
        container.accountStatus { [weak self] accountStatus, error in
            guard error == nil else { return }
            self?.isUserEligibleSubject.send(accountStatus == .available)
        }
    }

    private func bind() {
        notificationCenter.publisher(for: .CKAccountChanged)
            .sink { [weak self] _ in self?.refreshUserEligibility() }
            .store(in: &subscriptions)
    }
}
