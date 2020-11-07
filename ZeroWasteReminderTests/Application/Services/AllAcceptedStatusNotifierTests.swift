@testable import ZeroWasteReminder
import XCTest
import Combine

class AllAcceptedStatusNotifierTest: XCTestCase {
    private var sut: StatusNotifier!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.sut = AllAcceptedStatusNotifier()
        self.subscriptions = []
    }

    override func tearDown() {
        self.subscriptions = nil
        self.sut = nil
        super.tearDown()
    }

    func test_remoteStatus_returnsConnected() {
        let expectation = self.expectation(description: "")
        var remoteStatus: RemoteStatus?

        sut.remoteStatus
            .sink {
                remoteStatus = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(remoteStatus, .connected)
    }

    func test_notificationStatus_returnsAuthorized() {
        let expectation = self.expectation(description: "")
        var notificationStatus: NotificationConsentStatus?

        sut.notificationStatus
            .sink {
                notificationStatus = $0
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(notificationStatus, .authorized)
    }
}
