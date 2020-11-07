internal struct DependencyRecorderComposite: DependencyRecorder {
    private var recorders: [DependencyRecorder]

    internal init(_ recorders: [DependencyRecorder]) {
        self.recorders = recorders
    }

    internal func register() {
        recorders.forEach { $0.register() }
    }
}
