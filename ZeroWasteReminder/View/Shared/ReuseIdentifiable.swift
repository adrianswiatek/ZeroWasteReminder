public protocol ReuseIdentifiable {
    static var identifier: String { get }
}

extension ReuseIdentifiable {
    public static var identifier: String {
        "\(self)"
    }
}
