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

    public func selected() -> Self {
        .init(filterType, isSelected: true)
    }

    public func deselected() -> Self {
        .init(filterType, isSelected: false)
    }
}

public extension ItemsFilterCellViewModel {
    static func fromFilterType(_ filterType: ItemsFilterType) -> Self {
        .init(filterType, isSelected: filterType == .all)
    }
}
