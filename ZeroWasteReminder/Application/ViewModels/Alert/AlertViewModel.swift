import Combine
import Foundation

public final class AlertViewModel {
    @Published public private(set) var selectedOption: AlertOption
    @Published private var isCalendarShown: Bool

    public let dateCellViewModel: AlertDateCellViewModel
    public let requestSubject: PassthroughSubject<Request, Never>

    public var numberOfCells: Int {
        cellsData.count
    }

    public var indexOfCalendarCell: Int? {
        cellsData.firstIndex(of: .calendar)
    }

    private var cellsData: [CellData]

    private let eventDispatcher: EventDispatcher
    private var subscriptions: Set<AnyCancellable>

    public init(selectedOption: AlertOption, eventDispatcher: EventDispatcher) {
        self.selectedOption = selectedOption
        self.eventDispatcher = eventDispatcher
        self.dateCellViewModel = .fromAlertOption(selectedOption)

        self.isCalendarShown = false
        self.cellsData = []

        self.requestSubject = .init()
        self.subscriptions = []

        self.fillCellsData()
        self.bind()
    }

    public func cellDataForRow(at index: Int) -> CellData {
        cellsData[index]
    }

    public func indexOf(_ option: AlertOption) -> Int? {
        if case .customDate = option {
            return cellsData.firstIndex(of: .date)
        } else {
            return cellsData.firstIndex(of: .option(option))
        }
    }

    public func selectCell(at index: Int) {
        assert(0 ..< cellsData.count ~= index, "Invalid index.")

        switch cellsData[index] {
        case .calendar:
            break
        case .date where isCalendarShown:
            selectOption(.customDate(dateCellViewModel.date))
        case .date:
            isCalendarShown = true
            dateCellViewModel.isCalendarShown = true
        case .option(let option):
            selectOption(option)
        }
    }

    private func bind() {
        $isCalendarShown
            .sink { [weak self] in self?.setCalendarCell($0) }
            .store(in: &subscriptions)
    }

    private func setCalendarCell(_ isShown: Bool) {
        if isShown {
            cellsData.append(.calendar)
            requestSubject.send(.showCalendar)
        } else {
            cellsData.removeAll { $0 == .calendar }
            requestSubject.send(.hideCalendar)
        }
    }

    private func fillCellsData() {
        cellsData += [
            .option(.none),
            .option(.onDayOfExpiration),
            .option(.daysBefore(1)),
            .option(.daysBefore(2)),
            .option(.daysBefore(3)),
            .option(.weeksBefore(1)),
            .option(.weeksBefore(2)),
            .option(.monthsBefore(1)),
            .date
        ]
    }

    private func selectOption(_ option: AlertOption) {
        eventDispatcher.dispatch(AlertSet(option))
        requestSubject.send(.dismiss)
    }
}

public extension AlertViewModel {
    enum Request {
        case dismiss
        case hideCalendar
        case showCalendar
    }

    enum CellData: Hashable {
        case option(_ option: AlertOption)
        case date
        case calendar
    }
}
