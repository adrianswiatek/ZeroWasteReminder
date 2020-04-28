public protocol ModeState {
    var mode: Mode { get }

    func done(on viewModel: ItemsListViewModel)
    func filter(on viewModel: ItemsListViewModel)
    func select(on viewModel: ItemsListViewModel)
}

extension ModeState {
    public var isAddButtonVisible: Bool {
        mode == .read
    }

    public var isMoreButtonVisible: Bool {
        mode == .read
    }

    public var isDoneButtonVisible: Bool {
        mode != .read
    }

    public var isDeleteButtonVisible: Bool {
        mode == .selection
    }

    public var isFilterButtonVisible: Bool {
        mode == .read
    }

    public var isClearButtonVisible: Bool {
        mode == .filtering
    }

    public var isItemsListEditing: Bool {
        mode == .selection
    }

    public func done(on viewModel: ItemsListViewModel) {
        viewModel.modeState = ReadModeState()
    }

    public func filter(on viewModel: ItemsListViewModel) {
        viewModel.modeState = self
    }

    public func select(on viewModel: ItemsListViewModel) {
        viewModel.modeState = self
    }
}
