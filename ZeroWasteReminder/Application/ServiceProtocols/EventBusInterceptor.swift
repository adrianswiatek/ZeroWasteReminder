public protocol EventBusInterceptor {
    init(_ eventBus: EventBus)

    func startIntercept()
    func stopIntercept()
}
