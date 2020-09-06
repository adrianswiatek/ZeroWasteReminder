import Combine

public final class AlwaysEligibleAccountService: AccountService {
    public var isUserEligible: AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    public func refreshUserEligibility() {}
}
