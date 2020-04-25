import Combine

public final class ItemsFilterViewModel {
    public var cellViewModels: AnyPublisher<[ItemsFilterCellViewModel], Never> {
        cellViewModelsSubject.eraseToAnyPublisher()
    }

    private let cellViewModelsSubject: CurrentValueSubject<[ItemsFilterCellViewModel], Never>

    public init() {
        let cellViewModels = ItemsFilterType.allCases.map {
            ItemsFilterCellViewModel.fromFilterType($0)
        }

        cellViewModelsSubject = .init(cellViewModels)
    }

    public func toggleItem(atIndex index: Int) {
        var cells = cellViewModelsSubject.value
        let updatedCell = cells[index].toggled()

        cells[index] = updatedCell

        if updatedCell.filterType != .all && cells[0].isSelected {
            cells[0] = cells[0].toggled()
            cellViewModelsSubject.value = cells
            return
        }

        if updatedCell.filterType == .all && updatedCell.isSelected {
            cellViewModelsSubject.value = [updatedCell] + cells.filter { $0.filterType != .all }.map { $0.deselected() }
            return
        }

        if cells.allSatisfy({ !$0.isSelected }) {
            cells[0] = cells[0].toggled()
        }

        cellViewModelsSubject.value = cells
    }
}
