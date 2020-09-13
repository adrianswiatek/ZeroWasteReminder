import Foundation

public extension NSNotification.Name {
    static let itemCreateReceived = NSNotification.Name("itemCreateReceived")
    static let itemRemoveReceived = NSNotification.Name("itemRemoveReceived")
    static let itemUpdateReceived = NSNotification.Name("itemUpdateReceived")

    static let listCreateReceived = NSNotification.Name("listCreateReceived")
    static let listRemoveReceived = NSNotification.Name("listRemoveReceived")
    static let listUpdateReceived = NSNotification.Name("listUpdateReceived")
}
