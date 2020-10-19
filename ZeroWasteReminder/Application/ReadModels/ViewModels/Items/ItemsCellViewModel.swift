import Foundation

public final class ItemsCellViewModel {
    public let itemName: String
    public let hasNotes: Bool
    public let hasAlert: Bool
    public let expirationDate: String

    public let remainingViewModel: RemainingViewModel

    public init(_ item: Item, dateFormatter: DateFormatter) {
        self.itemName = item.name
        self.hasNotes = !item.notes.isEmpty
        self.hasAlert = item.alertOption != .none

        if case .date(let date) = item.expiration {
            expirationDate = dateFormatter.string(from: date)
        } else {
            expirationDate = "[not defined]"
        }

        self.remainingViewModel = RemainingViewModel(item)
    }
}
