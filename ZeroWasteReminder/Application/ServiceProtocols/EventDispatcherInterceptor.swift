public protocol EventDispatcherInterceptor {
    init(_ eventDispatcher: EventDispatcher)

    func startIntercept()
    func stopIntercept()
}
