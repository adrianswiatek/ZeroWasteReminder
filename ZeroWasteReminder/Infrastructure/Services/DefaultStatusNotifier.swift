import AVFoundation
import Combine
import Foundation
import Network
import NotificationCenter

public final class DefaultStatusNotifier: StatusNotifier {
    public var remoteStatus: AnyPublisher<RemoteStatus, Never> {
        remoteStatusSubject.receive(on: DispatchQueue.main).share().eraseToAnyPublisher()
    }

    public var notificationStatus: AnyPublisher<NotificationConsentStatus, Never> {
        notificationStatusSubject.removeDuplicates().eraseToAnyPublisher()
    }

    public var cameraStatus: AnyPublisher<CameraConsentStatus, Never> {
        cameraStatusSubject.removeDuplicates().eraseToAnyPublisher()
    }

    private let remoteStatusSubject: CurrentValueSubject<RemoteStatus, Never>
    private let networkReachabilitySubject: CurrentValueSubject<NWPath.Status, Never>
    private let notificationStatusSubject: CurrentValueSubject<NotificationConsentStatus, Never>
    private let cameraStatusSubject: CurrentValueSubject<CameraConsentStatus, Never>

    private let networkMonitor: NWPathMonitor
    private let accountService: AccountService
    private let userNotificationCenter: UNUserNotificationCenter

    private var subscriptions: Set<AnyCancellable>

    public init(accountService: AccountService, userNotificationCenter: UNUserNotificationCenter) {
        self.accountService = accountService
        self.userNotificationCenter = userNotificationCenter
        self.networkMonitor = .init()

        self.remoteStatusSubject = .init(.notDetermined)
        self.networkReachabilitySubject = .init(.requiresConnection)
        self.notificationStatusSubject = .init(.denied)
        self.cameraStatusSubject = .init(.notDetermined)

        self.subscriptions = []

        self.setupNetworkMonitor()
        self.bind()
        self.refresh()
    }

    public func refresh() {
        userNotificationCenter.getNotificationSettings { [weak self] in
            self?.notificationStatusSubject.send(.from($0.authorizationStatus))
        }

        cameraStatusSubject.send(.from(AVCaptureDevice.authorizationStatus(for: .video)))
    }

    private func setupNetworkMonitor() {
        networkMonitor.start(queue: .global(qos: .background))
        networkMonitor.pathUpdateHandler = { [weak self] in
            self?.networkReachabilitySubject.send($0.status)
        }
    }

    private func bind() {
        Publishers.CombineLatest(accountService.isUserEligible, networkReachabilitySubject)
            .sink { [weak self] in self?.sendRemoteStatus(isUserEligible: $0, networkStatus: $1) }
            .store(in: &subscriptions)
    }

    private func sendRemoteStatus(isUserEligible: Bool, networkStatus: NWPath.Status) {
        switch (isUserEligible, networkStatus) {
        case (true, .satisfied):
            remoteStatusSubject.value = .connected
        case (false, _):
            remoteStatusSubject.value = .notConnected(.remoteAccountNotFound)
        case (_, .unsatisfied):
            remoteStatusSubject.value = .notConnected(.badInternetConnection)
        case (_, .requiresConnection):
            remoteStatusSubject.value = .notConnected(.noInternetConnection)
        @unknown default:
            assertionFailure("Unknown network status.")
        }
    }
}
