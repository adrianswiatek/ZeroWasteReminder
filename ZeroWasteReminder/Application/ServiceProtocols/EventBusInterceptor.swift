public protocol eventDispatcherInterceptor {
    init(_ eventDispatcher: EventDispatcher)

    func startIntercept()
    func stopIntercept()
}
