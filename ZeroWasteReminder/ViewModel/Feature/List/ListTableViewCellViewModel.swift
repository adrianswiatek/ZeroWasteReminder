import Foundation

public final class ListTableViewCellViewModel {
    public var itemName: String {
        item.name
    }

    public var expirationDate: String {
        if case .date(let date) = item.expiration {
            return dateFormatter.string(from: date)
        }
        return "[not defined]"
    }

    private let item: Item
    private let dateFormatter: DateFormatter

    public init(_ item: Item, dateFormatter: DateFormatter) {
        self.item = item
        self.dateFormatter = dateFormatter
    }
}
