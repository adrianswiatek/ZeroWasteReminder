import Combine

public protocol ListItemsChangeListener {
    var updatedItemInList: AnyPublisher<List, Never> { get }

    func startListeningForItemChange(in list: List)
    func stopListening()
}
