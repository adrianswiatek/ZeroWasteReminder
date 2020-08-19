public enum AppError: Error {
    case general(_ message: String)

    public var localizedDescription: String {
        switch self {
        case .general(let message):
            return message
        }
    }

    public init(_ error: Error) {
        self = .general(error.localizedDescription)
    }
}
