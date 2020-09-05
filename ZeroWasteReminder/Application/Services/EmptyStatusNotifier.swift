import Combine

public final class EmptyStatusNotifier: StatusNotifier {
    public var remoteStatus: AnyPublisher<RemoteStatus, Never> {
        Just(.connected).eraseToAnyPublisher()
    }
}
