public struct AlertSet: AppEvent {
    public let option: AlertOption

    public init(_ option: AlertOption) {
        self.option = option
    }
}

extension AlertSet {
    public var description: String {
        "\(name)(option: \(option.formatted(.longDate)))"
    }
}
