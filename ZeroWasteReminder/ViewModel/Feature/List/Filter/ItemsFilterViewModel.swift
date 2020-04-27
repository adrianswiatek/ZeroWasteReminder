import Combine

public final class ItemsFilterViewModel {
    public var cellViewModels: AnyPublisher<[ItemsFilterCellViewModel], Never> {
        cellViewModelsSubject.eraseToAnyPublisher()
    }

    public var indexToScroll: Int {
        cellViewModelsSubject.value.firstIndex { $0.isSelected } ?? 0
    }

    private let cellViewModelsSubject: CurrentValueSubject<[ItemsFilterCellViewModel], Never>

    public init() {
        let remainingStates: [RemainingState] = [
            .notDefined,
            .expired,
            .almostExpired,
            .valid(value: 0, component: .day)
        ]

        cellViewModelsSubject = .init(remainingStates.map(ItemsFilterCellViewModel.init))
    }

    public func toggleItem(atIndex index: Int) {
        var cells = cellViewModelsSubject.value
        cells[index] = cells[index].toggled()
        cellViewModelsSubject.value = cells
    }
}
