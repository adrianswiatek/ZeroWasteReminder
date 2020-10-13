import Foundation

internal struct ItemSnapshot: Equatable {
    private let name: String
    private let notes: String
    private let expirationDate: Date?
    private let alertOption: AlertOption

    internal init(name: String, notes: String, expirationDate: Date?, alertOption: AlertOption) {
        self.name = name
        self.notes = notes
        self.expirationDate = expirationDate
        self.alertOption = alertOption
    }

    internal func equals(_ item: Item?) -> Bool {
        return item?.name == name
            && item?.notes == notes
            && item?.expiration.date == expirationDate
            && item?.alertOption == alertOption
    }
}
