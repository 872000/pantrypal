import XCTest
@testable import PantryPal

final class PantryTests: XCTestCase {

    func samplePantry() -> Pantry {
        Pantry(items: [
            makeItem("Milk", expiresInDays: 1, category: .dairy),
            makeItem("Yogurt", expiresInDays: -2, category: .dairy),
            makeItem("Canned Beans", expiresInDays: 200, category: .canned),
            makeItem("Rice"), // no expiry
            makeItem("Cheese", expiresInDays: 5, category: .dairy),
        ])
    }

    func testExpiredFilter() {
        let expired = samplePantry().expired(asOf: testNow)
        XCTAssertEqual(expired.map(\.name), ["Yogurt"])
    }

    func testExpiringSoonFilter() {
        let soon = samplePantry().expiringSoon(asOf: testNow)
        XCTAssertEqual(soon.map(\.name), ["Milk"])
    }

    func testExpiringSoonSortedByUrgency() {
        var pantry = Pantry()
        pantry.add(makeItem("A", expiresInDays: 3))
        pantry.add(makeItem("B", expiresInDays: 1))
        pantry.add(makeItem("C", expiresInDays: 2))
        XCTAssertEqual(pantry.expiringSoon(asOf: testNow).map(\.name), ["B", "C", "A"])
    }

    func testSortedByExpiryPutsNoExpiryLast() {
        let sorted = samplePantry().sortedByExpiry(asOf: testNow).map(\.name)
        XCTAssertEqual(sorted.first, "Yogurt")      // expired first
        XCTAssertEqual(sorted.last, "Rice")        // no expiry last
        XCTAssertEqual(sorted[1], "Milk")          // then soonest
    }

    func testSearchIsCaseInsensitive() {
        let results = samplePantry().search("MILK")
        XCTAssertEqual(results.map(\.name), ["Milk"])
    }

    func testSearchEmptyQueryReturnsAll() {
        XCTAssertEqual(samplePantry().search("").count, 5)
    }

    func testItemsInCategory() {
        XCTAssertEqual(samplePantry().items(in: .dairy).count, 3)
    }

    func testWasteSummary() {
        let summary = samplePantry().wasteSummary(asOf: testNow)
        XCTAssertEqual(summary.expired, 1)
        XCTAssertEqual(summary.expiringSoon, 1)
        XCTAssertEqual(summary.fresh, 2)
        XCTAssertEqual(summary.noExpiry, 1)
    }

    func testAddUpdateRemove() {
        var pantry = Pantry()
        var item = makeItem("Eggs", expiresInDays: 7)
        pantry.add(item)
        XCTAssertEqual(pantry.items.count, 1)

        item.quantity = 12
        pantry.update(item)
        XCTAssertEqual(pantry.items.first?.quantity, 12)

        pantry.remove(id: item.id)
        XCTAssertTrue(pantry.items.isEmpty)
    }

    func testJSONRoundTrip() throws {
        let pantry = samplePantry()
        let restored = try Pantry.decodeFromJSON(pantry.encodeToJSON())
        XCTAssertEqual(restored, pantry)
    }
}
