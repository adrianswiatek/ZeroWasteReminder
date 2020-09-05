public final class MoveItemViewModelFactory {
    private let moveItemService: MoveItemService

    public init(moveItemService: MoveItemService) {
        self.moveItemService = moveItemService
    }

    public func create(for item: Item) -> MoveItemViewModel {
        .init(item: item, moveItemService: moveItemService)
    }
}
