public struct ErrorOccured: AppEvent {
    public let error: AppError

    public init(_ error: AppError) {
        self.error = error
    }
}

extension ErrorOccured {
    public var description: String {
        "\(name)(message: \(error.localizedDescription))"
    }
}
