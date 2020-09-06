import Combine

public protocol ListItemsChangeListener {
    var updatedItemInLists: AnyPublisher<[List], Never> { get }

    func startListeningForItemChange(in list: List)
    func stopListening()
}
