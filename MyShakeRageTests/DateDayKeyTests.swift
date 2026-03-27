import XCTest
@testable import MyShakeRage

final class DateDayKeyTests: XCTestCase {
    func testDayKeyUsesStableCalendarDate() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: 2026,
            month: 3,
            day: 27,
            hour: 23,
            minute: 59
        )

        let date = try XCTUnwrap(components.date)
        XCTAssertEqual(date.dayKey(calendar: calendar), "2026-03-27")
    }
}
