public struct ErrorEvent: AppEvent {
    public let error: AppError

    public init(_ error: AppError) {
        self.error = error
    }
}
