import Foundation

public enum PantryCategory: String, Codable, CaseIterable, Sendable {
    case produce
    case dairy
    case meat
    case grains
    case canned
    case frozen
    case spices
    case beverages
    case snacks
    case other

    public var label: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}

/// Freshness of an item relative to a reference date.
public enum ExpiryStatus: Equatable, Sendable {
    case expired(daysAgo: Int)
    case expiringSoon(daysLeft: Int)
    case fresh(daysLeft: Int)
    case noExpiry

    public var isActionable: Bool {
        switch self {
        case .expired, .expiringSoon: return true
        case .fresh, .noExpiry: return false
        }
    }
}

public struct PantryItem: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var quantity: Double
    public var unit: String
    public var category: PantryCategory
    public var expiryDate: Date?
    public var addedDate: Date
    public var notes: String

    public init(
        id: UUID = UUID(),
        name: String,
        quantity: Double = 1,
        unit: String = "",
        category: PantryCategory = .other,
        expiryDate: Date? = nil,
        addedDate: Date = Date(),
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.expiryDate = expiryDate
        self.addedDate = addedDate
        self.notes = notes
    }

    /// Whole days from `now` until expiry, measured start-of-day to start-of-day.
    /// Negative when expired. Nil when the item has no expiry date.
    public func daysUntilExpiry(asOf now: Date, calendar: Calendar = .current) -> Int? {
        guard let expiryDate else { return nil }
        let startNow = calendar.startOfDay(for: now)
        let startExpiry = calendar.startOfDay(for: expiryDate)
        return calendar.dateComponents([.day], from: startNow, to: startExpiry).day
    }

    public func status(
        asOf now: Date,
        soonThresholdDays: Int = 3,
        calendar: Calendar = .current
    ) -> ExpiryStatus {
        guard let days = daysUntilExpiry(asOf: now, calendar: calendar) else {
            return .noExpiry
        }
        if days < 0 { return .expired(daysAgo: -days) }
        if days <= soonThresholdDays { return .expiringSoon(daysLeft: days) }
        return .fresh(daysLeft: days)
    }
}
