@testable import ZeroWasteReminder
import XCTest

class ExpirationTests: XCTestCase {
    func test_date_withNoneCase_returnsNil() {
        XCTAssertNil(Expiration.none.date)
    }

    func test_date_withDateCase_returnsGivenDate() {
        let date: Date = .init()
        XCTAssertEqual(Expiration.date(date).date, date)
    }

    func test_fromDate_withNilArgument_returnsNoneCase() {
        XCTAssertEqual(Expiration.fromDate(nil), Expiration.none)
    }

    func test_fromDate_withDateArgument_returnsDateCase() {
        let date: Date = .init()
        XCTAssertEqual(Expiration.fromDate(date), Expiration.date(date))
    }

    func test_equals_withTwoNoneCases_returnsTrue() {
        XCTAssertEqual(Expiration.none, Expiration.none)
    }

    func test_equals_withOneNoneCaseAndSecondDate_returnsFalse() {
        XCTAssertNotEqual(Expiration.none, Expiration.date(.init()))
        XCTAssertNotEqual(Expiration.date(.init()), Expiration.none)
    }

    func test_equals_withTwoDateCasesAndTheSameDates_retursTrue() {
        let date: Date = .init()
        XCTAssertEqual(Expiration.date(date), Expiration.date(date))
    }

    func test_equals_withTwoDateCasesThatDifferInLessThanDay_returnsTrue() {
        let firstDate: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 15, hour: 9
        ))!
        let secondDate: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 15, hour: 20
        ))!
        XCTAssertEqual(Expiration.date(firstDate), Expiration.date(secondDate))
    }

    func test_equals_withTwoDateCasesThatDifferInMoreThanDay_returnsTrue() {
        let firstDate: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 15, hour: 9
        ))!
        let secondDate: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 16, hour: 9
        ))!
        XCTAssertNotEqual(Expiration.date(firstDate), Expiration.date(secondDate))
    }

    func test_isLessThan_withTwoNoneCases_returnsFalse() {
        XCTAssertFalse(Expiration.none < Expiration.none)
    }

    func test_isLessThan_withFirstNoneCaseAndSecondDateCase_returnsTrue() {
        XCTAssertTrue(Expiration.none < Expiration.date(.init()))
    }

    func test_isLessThan_withFirstDateCaseAndSecondNoneCase_returnsFalse() {
        XCTAssertFalse(Expiration.date(.init()) < Expiration.none)
    }

    func test_isLessThan_withFirstSoonerAndSecondLaterDateCases_returnsTrue() {
        let firstDate: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 15, hour: 9
        ))!
        let secondDate: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 16, hour: 9
        ))!
        XCTAssertTrue(Expiration.date(firstDate) < Expiration.date(secondDate))
    }
}
