import Combine

public protocol EventBus {
    var events: AnyPublisher<AppEvent, Never> { get }
    func send(_ event: AppEvent)
}
