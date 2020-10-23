@testable import ZeroWasteReminder
import XCTest

class IdTests: XCTestCase {
    func test_asUuid_whenCreatedFromUuid_returnsTheSameUuid() {
        let uuid: UUID = .init()
        let sut: Id<Any> = .fromUuid(uuid)
        XCTAssertEqual(sut.asUuid, uuid)
    }

    func test_asUuid_whenCreatedFromString_returnsTheSameUuid() {
        let uuid: UUID = .init()
        let sut: Id<Any> = .fromString(uuid.uuidString)
        XCTAssertEqual(sut.asUuid, uuid)
    }

    func test_asString_whenCreatedFromUuid_returnsTheSameUuidString() {
        let uuid: UUID = .init()
        let sut: Id<Any> = .fromUuid(uuid)
        XCTAssertEqual(sut.asString, uuid.uuidString)
    }

    func test_asString_whenCreatedFromString_returnsTheSameUuidString() {
        let uuid: UUID = .init()
        let sut: Id<Any> = .fromString(uuid.uuidString)
        XCTAssertEqual(sut.asString, uuid.uuidString)
    }

    func test_equals_whenTheSameUuids_returnsTrue() {
        let uuid: UUID = .init()
        let firstId: Id<Any> = .fromUuid(uuid)
        let secondId: Id<Any> = .fromUuid(uuid)
        XCTAssertEqual(firstId, secondId)
    }

    func test_equals_whenTheSameUuidsButDifferentTypes_returnsFalse() {
        let firstId: Id<Any> = .fromUuid(.init())
        let secondId: Id<Any> = .fromUuid(.empty)
        XCTAssertNotEqual(firstId, secondId)
    }
}
