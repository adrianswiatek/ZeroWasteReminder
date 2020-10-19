import Foundation

public extension DateFormatter {
    static var fullDate: DateFormatter {
        configure(DateFormatter()) { $0.dateStyle = .full }
    }

    static var longDate: DateFormatter {
        configure(DateFormatter()) { $0.dateStyle = .long }
    }

    static func withFormat(_ format: String) -> DateFormatter {
        configure(DateFormatter()) { $0.dateFormat = format }
    }
}
