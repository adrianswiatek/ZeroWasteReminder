internal struct DependencyContainerConfiguration {
    internal let localStorage: LocalStorage
    internal let remoteStorage: RemoteStorage
}

internal extension DependencyContainerConfiguration {
    enum LocalStorage {
        case inMemory
        case coreData
    }

    enum RemoteStorage {
        case inMemory
        case cloudKit(containerIdentifier: String)
    }
}
