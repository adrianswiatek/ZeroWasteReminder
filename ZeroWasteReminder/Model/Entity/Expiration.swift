import Foundation

public enum Expiration: Hashable {
    case none
    case date(_ date: Date)
}
