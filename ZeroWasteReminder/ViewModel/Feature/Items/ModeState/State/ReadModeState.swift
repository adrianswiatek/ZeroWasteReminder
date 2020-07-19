public struct ReadModeState: ModeState {
    public let mode: Mode = .read

    public func filter(on viewModel: ItemsViewModel) {
        viewModel.modeState = FilteringModeState()
    }

    public func select(on viewModel: ItemsViewModel) {
        viewModel.modeState = SelectionModeState()
    }
}
