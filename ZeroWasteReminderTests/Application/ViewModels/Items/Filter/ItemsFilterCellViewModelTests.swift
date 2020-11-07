@testable import ZeroWasteReminder
import XCTest

class ItemsFilterCellViewModelTests: XCTestCase {
    func test_title_withNotDefinedState_returnsNotDefined() {
        let sut = ItemsFilterCellViewModel(.notDefined)
        XCTAssertEqual(sut.title, "Not defined")
    }

    func test_title_withExpiredState_returnsExpired() {
        let sut = ItemsFilterCellViewModel(.expired)
        XCTAssertEqual(sut.title, "Expired")
    }

    func test_title_withAlmostExpiredState_returnsAlmostExpired() {
        let sut = ItemsFilterCellViewModel(.almostExpired)
        XCTAssertEqual(sut.title, "Almost expired")
    }

    func test_title_withValidState_returnsValid() {
        let sut = ItemsFilterCellViewModel(.valid(value: 1, component: .day))
        XCTAssertEqual(sut.title, "Valid")
    }

    func test_toggled_returnsObjectWithToggledIsSelected() {
        let sut = ItemsFilterCellViewModel(.notDefined)
        let updatedSut = sut.toggled()

        XCTAssertFalse(sut.isSelected)
        XCTAssertTrue(updatedSut.isSelected)
    }

    func test_deselect_returnsObjectWithDeselectedState() {
        let sut = ItemsFilterCellViewModel(.notDefined).toggled()
        let updatedSut = sut.deselected()

        XCTAssertTrue(sut.isSelected)
        XCTAssertFalse(updatedSut.isSelected)
    }
}
