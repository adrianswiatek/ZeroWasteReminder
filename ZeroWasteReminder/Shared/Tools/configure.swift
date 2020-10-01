public func configure<T>(_ object: T, with: (inout T) -> Void) -> T {
    var object = object
    with(&object)
    return object
}
