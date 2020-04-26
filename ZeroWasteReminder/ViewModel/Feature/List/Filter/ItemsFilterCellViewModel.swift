import Combine

public struct ItemsFilterCellViewModel: Hashable {
    public let isSelected: Bool
    public let filterType: ItemsFilterType

    public var title: String {
        filterType.rawValue
    }

    private init(_ filterType: ItemsFilterType, isSelected: Bool) {
        self.filterType = filterType
        self.isSelected = isSelected
    }

    public func toggled() -> Self {
        .init(filterType, isSelected: !isSelected)
    }

    public func deselected() -> Self {
        .init(filterType, isSelected: false)
    }

    public func filter(_ items: [Item]) -> [Item] {
        guard isSelected else { return [] }

        switch filterType {
        case .all:
            return items
        case .notDefined:
            return items.filter { RemainingViewModel($0).state == .notDefined }
        case .expired:
            return items.filter { RemainingViewModel($0).state == .expired }
        case .almostExpired:
            return items.filter { RemainingViewModel($0).state == .almostExpired }
        case .beforeExpiration:
            return items.filter {
                let state = RemainingViewModel($0).state
                return state != .notDefined && state != .expired && state != .almostExpired
            }
        }
    }
}

public extension ItemsFilterCellViewModel {
    static func fromFilterType(_ filterType: ItemsFilterType) -> Self {
        .init(filterType, isSelected: filterType == .all)
    }
}
