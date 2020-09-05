import Combine

public final class InMemoryAccountService: AccountService {
    public var isUserEligible: AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    public func refreshUserEligibility() {}
}
