internal struct DependenciesRecorderComposite: DependenciesRecorder {
    private var recorders: [DependenciesRecorder]

    internal init(_ recorders: [DependenciesRecorder]) {
        self.recorders = recorders
    }

    internal func register() {
        recorders.forEach { $0.register() }
    }
}
