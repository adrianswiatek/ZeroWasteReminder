import Foundation

public extension NSNotification.Name {
    static let itemAddReceived = NSNotification.Name("itemAddReceived")
    static let itemRemoveReceived = NSNotification.Name("itemRemoveReceived")
    static let itemUpdateReceived = NSNotification.Name("itemUpdateReceived")

    static let listAddReceived = NSNotification.Name("listAddReceived")
    static let listRemoveReceived = NSNotification.Name("listRemoveReceived")
    static let listUpdateReceived = NSNotification.Name("listUpdateReceived")
}
