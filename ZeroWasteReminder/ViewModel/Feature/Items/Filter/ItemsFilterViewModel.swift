import Combine

public final class ItemsFilterViewModel {
    public var cellViewModels: AnyPublisher<[ItemsFilterCellViewModel], Never> {
        cellViewModelsSubject.eraseToAnyPublisher()
    }

    public var numberOfSelectedCells: AnyPublisher<Int, Never> {
        cellViewModels.map { $0.filter { cell in cell.isSelected }.count }.eraseToAnyPublisher()
    }

    public var totalNumberOfCells: Int {
        cellViewModelsSubject.value.count
    }

    public var indexToScroll: Int {
        cellViewModelsSubject.value.firstIndex { $0.isSelected } ?? 0
    }

    public var isFilterActive: Bool {
        cellViewModelsSubject.value.first { $0.isSelected } != nil
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

    public func toggleItem(at index: Int) {
        var cells = cellViewModelsSubject.value
        cells[index] = cells[index].toggled()
        cellViewModelsSubject.value = cells
    }

    public func deselectAll() {
        let cells = cellViewModelsSubject.value
        cellViewModelsSubject.value = cells.map { $0.deselected() }
    }
}
