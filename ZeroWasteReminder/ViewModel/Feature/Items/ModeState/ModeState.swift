public protocol ModeState {
    var mode: Mode { get }

    func done(on viewModel: ItemsViewModel)
    func filter(on viewModel: ItemsViewModel)
    func select(on viewModel: ItemsViewModel)
}

extension ModeState {
    public var isAddButtonVisible: Bool { mode == .read }
    public var isMoreButtonVisible: Bool { mode == .read }
    public var isDoneButtonVisible: Bool { mode != .read }
    public var isDeleteButtonVisible: Bool { mode == .selection }
    public var isFilterButtonVisible: Bool { mode == .read }
    public var isFilterBadgeVisible: Bool { mode == .read }
    public var isClearButtonVisible: Bool { mode == .filtering }
    public var areItemsEditing: Bool { mode == .selection }

    public func done(on viewModel: ItemsViewModel) {
        viewModel.modeState = ReadModeState()
    }

    public func filter(on viewModel: ItemsViewModel) {
        viewModel.modeState = self
    }

    public func select(on viewModel: ItemsViewModel) {
        viewModel.modeState = self
    }
}
