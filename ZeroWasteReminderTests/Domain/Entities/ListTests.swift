@testable import ZeroWasteReminder
import XCTest

class ListTests: XCTestCase {
    func test_withName_returnsListWithUpdatedName() {
        let list = List(id: .fromUuid(UUID()), name: "The list")
        let updatedList = list.withName("New name")
        XCTAssertEqual(updatedList.name, "New name")
    }

    func test_withUpdateDate_returnsListWithUpdatedDate() {
        let list = List(id: .fromUuid(UUID()), name: "The list")
        let newDate = Date().adding(1, .day)

        let updatedList = list.withUpdateDate(newDate)

        XCTAssertEqual(updatedList.updateDate, newDate)
    }
}
