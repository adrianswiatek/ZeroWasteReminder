import Foundation

public struct ValidationRules {
    private let validationRules: [ValidationRule]

    public init(_ validationRules: ValidationRule...) {
        self.validationRules = validationRules
    }

    public func areValid(_ text: String) -> Bool {
        validationRules.allSatisfy { $0.isValid(text) }
    }
}

public struct ValidationRule {
    public var isValid: (_ text: String) -> Bool
}

public extension ValidationRule {
    static var isNotEmpty: ValidationRule {
        .init { !$0.isEmpty }
    }

    static var doesNotStartFromZero: ValidationRule {
        .init { $0.prefix(1) != "0" }
    }

    static func hasMaxCount(_ maxCount: Int) -> ValidationRule {
        .init { $0.count <= maxCount }
    }

    static var isPositiveNumber: ValidationRule {
        .init {
            guard !$0.isEmpty else { return true }
            guard let value = Int($0) else { return false }
            return value >= 0
        }
    }
}
