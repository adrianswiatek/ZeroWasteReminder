import Combine

public protocol AccountService {
    var isUserEligible: AnyPublisher<Bool, Never> { get }
    func refreshUserEligibility()
}
