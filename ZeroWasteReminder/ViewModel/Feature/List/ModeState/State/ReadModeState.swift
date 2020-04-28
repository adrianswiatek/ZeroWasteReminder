public struct ReadModeState: ModeState {
    public let mode: Mode = .read

    public func filter(on viewModel: ItemsListViewModel) {
        viewModel.modeState = FilteringModeState()
    }

    public func select(on viewModel: ItemsListViewModel) {
        viewModel.modeState = SelectionModeState()
    }
}
