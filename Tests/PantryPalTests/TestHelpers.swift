import XCTest
@testable import PantryPal

/// Fixed reference date: Monday 2026-10-05, 12:00 Toronto time.
let testNow: Date = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Toronto")!
    return calendar.date(from: DateComponents(year: 2026, month: 10, day: 5, hour: 12))!
}()

func daysFromNow(_ days: Int) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Toronto")!
    return calendar.date(byAdding: .day, value: days, to: testNow)!
}

func makeItem(_ name: String, expiresInDays: Int? = nil, category: PantryCategory = .other) -> PantryItem {
    PantryItem(
        name: name,
        quantity: 1,
        unit: "pc",
        category: category,
        expiryDate: expiresInDays.map(daysFromNow),
        addedDate: testNow
    )
}
