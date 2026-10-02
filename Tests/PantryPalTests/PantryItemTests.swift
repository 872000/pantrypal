import XCTest
@testable import PantryPal

final class PantryItemTests: XCTestCase {

    func testDaysUntilExpiry() {
        let item = makeItem("Milk", expiresInDays: 2)
        XCTAssertEqual(item.daysUntilExpiry(asOf: testNow), 2)
    }

    func testDaysUntilExpiryNegativeWhenExpired() {
        let item = makeItem("Yogurt", expiresInDays: -3)
        XCTAssertEqual(item.daysUntilExpiry(asOf: testNow), -3)
    }

    func testNilExpiryGivesNilDays() {
        let item = makeItem("Rice") // no expiry
        XCTAssertNil(item.daysUntilExpiry(asOf: testNow))
        XCTAssertEqual(item.status(asOf: testNow), .noExpiry)
    }

    func testExpiredStatus() {
        let item = makeItem("Yogurt", expiresInDays: -2)
        XCTAssertEqual(item.status(asOf: testNow), .expired(daysAgo: 2))
    }

    func testExpiringSoonStatus() {
        let item = makeItem("Milk", expiresInDays: 1)
        XCTAssertEqual(item.status(asOf: testNow), .expiringSoon(daysLeft: 1))
    }

    func testExpiringTodayCountsAsSoon() {
        let item = makeItem("Bread", expiresInDays: 0)
        XCTAssertEqual(item.status(asOf: testNow), .expiringSoon(daysLeft: 0))
    }

    func testFreshStatus() {
        let item = makeItem("Canned Beans", expiresInDays: 90)
        XCTAssertEqual(item.status(asOf: testNow), .fresh(daysLeft: 90))
    }

    func testCustomThreshold() {
        let item = makeItem("Cheese", expiresInDays: 5)
        // Default threshold (3 days): fresh. Wider threshold (7): expiring soon.
        XCTAssertEqual(item.status(asOf: testNow), .fresh(daysLeft: 5))
        XCTAssertEqual(item.status(asOf: testNow, soonThresholdDays: 7), .expiringSoon(daysLeft: 5))
    }
}
