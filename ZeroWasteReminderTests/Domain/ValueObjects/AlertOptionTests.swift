@testable import ZeroWasteReminder
import XCTest

class AlertOptionTests: XCTestCase {
    func test_fromString_with0_returnsOnDayOfExpirationCase() {
        XCTAssertEqual(AlertOption.fromString("0"), AlertOption.onDayOfExpiration)
    }

    func test_fromString_withDAndNumber_returnsDaysBeforeCase() {
        XCTAssertEqual(AlertOption.fromString("d1"), AlertOption.daysBefore(1))
        XCTAssertEqual(AlertOption.fromString("d10"), AlertOption.daysBefore(10))
    }

    func test_fromString_withWAndNumber_returnsWeeksBeforeCase() {
        XCTAssertEqual(AlertOption.fromString("w1"), AlertOption.weeksBefore(1))
        XCTAssertEqual(AlertOption.fromString("w10"), AlertOption.weeksBefore(10))
    }

    func test_fromString_withMAndNumber_returnsMonthsBeforeCase() {
        XCTAssertEqual(AlertOption.fromString("m1"), AlertOption.monthsBefore(1))
        XCTAssertEqual(AlertOption.fromString("m10"), AlertOption.monthsBefore(10))
    }

    func test_fromString_withProperlyFormattedDate_returnsCustomDateCase() {
        let date: Date = Calendar.appCalendar.date(from: .init(year: 2020, month: 6, day: 15))!
        let formattedDate = DateFormatter.withFormat("yyyy-MM-dd").string(from: date)
        XCTAssertEqual(AlertOption.fromString(formattedDate), AlertOption.customDate(date))
    }

    func test_fromString_withStringOtherThan0DWM_returnsNoneCase() {
        XCTAssertEqual(AlertOption.fromString(""), AlertOption.none)
        XCTAssertEqual(AlertOption.fromString("xyz"), AlertOption.none)
        XCTAssertEqual(AlertOption.fromString("123"), AlertOption.none)
    }

    func test_asString_withNoneCase_returnsEmptyString() {
        XCTAssertEqual(AlertOption.none.asString, "")
    }

    func test_asString_withOnDayOfExpirationCase_returnsZero() {
        XCTAssertEqual(AlertOption.onDayOfExpiration.asString, "0")
    }

    func test_asString_withDaysBeforeCase_returnsDAndNumberOfDays() {
        XCTAssertEqual(AlertOption.daysBefore(1).asString, "d1")
        XCTAssertEqual(AlertOption.daysBefore(10).asString, "d10")
    }

    func test_asString_withWeeksBeforeCase_returnsWAndNumberOfWeeks() {
        XCTAssertEqual(AlertOption.weeksBefore(1).asString, "w1")
        XCTAssertEqual(AlertOption.weeksBefore(10).asString, "w10")
    }

    func test_asString_withMonthsBeforeCase_returnsMAndNumberOfMonths() {
        XCTAssertEqual(AlertOption.monthsBefore(1).asString, "m1")
        XCTAssertEqual(AlertOption.monthsBefore(10).asString, "m10")
    }

    func test_asString_withCustomDateCase_returnsProperStringForEachCase() {
        let date = Date()
        let formattedDate = DateFormatter.withFormat("yyyy-MM-dd").string(from: date)
        XCTAssertEqual(AlertOption.customDate(date).asString, formattedDate)
    }

    func test_calculateDate_withNoneCase_returnsNil() {
        XCTAssertNil(AlertOption.none.calculateDate(from: .init()))
    }

    func test_calculateDate_withOnDayOfExpirationCase_returnsProperDate() {
        let date: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 15, hour: 12
        ))!
        let expected: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 15, hour: 9
        ))!

        let result = AlertOption.onDayOfExpiration.calculateDate(from: date)

        XCTAssertEqual(result, expected)
    }

    func test_calculateDate_withTwoDaysBeforeCase_returnsProperDate() {
        let date: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 15, hour: 12
        ))!
        let expected: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 13, hour: 9
        ))!

        let result = AlertOption.daysBefore(2).calculateDate(from: date)

        XCTAssertEqual(result, expected)
    }

    func test_calculateDate_withTwoWeeksBeforeCase_returnsProperDate() {
        let date: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 15, hour: 12
        ))!
        let expected: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 1, hour: 9
        ))!

        let result = AlertOption.weeksBefore(2).calculateDate(from: date)

        XCTAssertEqual(result, expected)
    }

    func test_calculateDate_withTwoMonthsBeforeCase_returnsProperDate() {
        let date: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 15, hour: 12
        ))!
        let expected: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 4, day: 15, hour: 9
        ))!

        let result = AlertOption.monthsBefore(2).calculateDate(from: date)

        XCTAssertEqual(result, expected)
    }

    func test_calculateDate_withCustomDateCase_returnsProperDate() {
        let date: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 15, hour: 12
        ))!
        let expected = date.settingTime(hour: 9)

        let result = AlertOption.customDate(date).calculateDate(from: .init())

        XCTAssertEqual(result, expected)
    }

    func test_formatted_withNoneCase_returnsFormattedString() {
        XCTAssertEqual(AlertOption.none.formatted(.longDate), .localized(.none))
    }

    func test_formatted_withOnDayOfExpirationCase_returnsFormattedString() {
        XCTAssertEqual(AlertOption.onDayOfExpiration.formatted(.longDate), .localized(.onDayOfExpiration))
    }

    func test_formatted_withDaysBeforeCase_returnsFormattedString() {
        XCTAssertEqual(AlertOption.daysBefore(1).formatted(.longDate), "1 day before")
        XCTAssertEqual(AlertOption.daysBefore(2).formatted(.longDate), "2 days before")
    }

    func test_formatted_withWeeksBeforeCase_returnsFormattedString() {
        XCTAssertEqual(AlertOption.weeksBefore(1).formatted(.longDate), "1 week before")
        XCTAssertEqual(AlertOption.weeksBefore(2).formatted(.longDate), "2 weeks before")
    }

    func test_formatted_withMonthsBeforeCase_returnsFormattedString() {
        XCTAssertEqual(AlertOption.monthsBefore(1).formatted(.longDate), "1 month before")
        XCTAssertEqual(AlertOption.monthsBefore(2).formatted(.longDate), "2 months before")
    }

    func test_formatted_withCustomDate_returnsFormattedString() {
        let date: Date = Calendar.appCalendar.date(from: .init(
            year: 2020, month: 6, day: 15, hour: 12
        ))!
        let formatter = DateFormatter.longDate
        let expected = formatter.string(from: date)

        let result = AlertOption.customDate(date).formatted(formatter)

        XCTAssertEqual(result, expected)
    }
}
