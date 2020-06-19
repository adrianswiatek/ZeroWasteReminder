import Combine
import Foundation

public final class RemoteStatusNotifier {
    private let remoteStatusSubject: CurrentValueSubject<RemoteStatus, Never>
    public var remoteStatus: AnyPublisher<RemoteStatus, Never> {
        remoteStatusSubject.share().eraseToAnyPublisher()
    }

    private let accountService: AccountService
    private var subscriptions: Set<AnyCancellable>

    public init(accountService: AccountService) {
        self.accountService = accountService

        self.remoteStatusSubject = .init(.notDetermined)
        self.subscriptions = []

        self.bind()
    }

    private func bind() {
        accountService.isUserEligible
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isUserEligible in
                self?.remoteStatusSubject.value = isUserEligible ? .connected : .notConnected(.remoteAccountNotFound)
            }
            .store(in: &subscriptions)
    }
}

public enum RemoteStatus: Equatable {
    case connected
    case notConnected(_ reason: Reason)
    case notDetermined
}

extension RemoteStatus {
    public enum Reason {
        case remoteAccountNotFound
    }
}
