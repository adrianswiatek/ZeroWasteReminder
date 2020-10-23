public enum AppError: Error {
    case ofType(_ type: AppErrorType)
    case general(_ message: String)

    public var localizedDescription: String {
        switch self {
        case .ofType(let type):
            return type.localDescription
        case .general(let message):
            return message
        }
    }

    public init(_ error: Error) {
        self = .general(error.localizedDescription)
    }
}

public protocol AppErrorType {
    var localDescription: String { get }
}
