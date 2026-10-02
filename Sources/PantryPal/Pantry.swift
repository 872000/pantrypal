import Foundation

/// In-memory pantry. Pure value type — encode to JSON for persistence.
public struct Pantry: Codable, Equatable, Sendable {
    public private(set) var items: [PantryItem]

    public init(items: [PantryItem] = []) {
        self.items = items
    }

    public mutating func add(_ item: PantryItem) {
        items.append(item)
    }

    public mutating func update(_ item: PantryItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
    }

    public mutating func remove(id: UUID) {
        items.removeAll { $0.id == id }
    }

    /// Case-insensitive name search.
    public func search(_ query: String) -> [PantryItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return items }
        return items.filter { $0.name.lowercased().contains(q) }
    }

    public func items(in category: PantryCategory) -> [PantryItem] {
        items.filter { $0.category == category }
    }

    public func expired(asOf now: Date) -> [PantryItem] {
        items.filter {
            if case .expired = $0.status(asOf: now) { return true }
            return false
        }
    }

    public func expiringSoon(asOf now: Date, withinDays: Int = 3) -> [PantryItem] {
        items.filter {
            if case .expiringSoon = $0.status(asOf: now, soonThresholdDays: withinDays) { return true }
            return false
        }
        .sorted { ($0.daysUntilExpiry(asOf: now) ?? .max) < ($1.daysUntilExpiry(asOf: now) ?? .max) }
    }

    /// Most urgent first: expired, then soonest expiry; items without an
    /// expiry date sort last.
    public func sortedByExpiry(asOf now: Date) -> [PantryItem] {
        items.sorted { lhs, rhs in
            let l = lhs.daysUntilExpiry(asOf: now) ?? .max
            let r = rhs.daysUntilExpiry(asOf: now) ?? .max
            return l < r
        }
    }

    public struct WasteSummary: Equatable, Sendable {
        public var expired: Int
        public var expiringSoon: Int
        public var fresh: Int
        public var noExpiry: Int
    }

    public func wasteSummary(asOf now: Date, withinDays: Int = 3) -> WasteSummary {
        var summary = WasteSummary(expired: 0, expiringSoon: 0, fresh: 0, noExpiry: 0)
        for item in items {
            switch item.status(asOf: now, soonThresholdDays: withinDays) {
            case .expired: summary.expired += 1
            case .expiringSoon: summary.expiringSoon += 1
            case .fresh: summary.fresh += 1
            case .noExpiry: summary.noExpiry += 1
            }
        }
        return summary
    }

    // MARK: - Persistence helpers

    public func encodeToJSON() throws -> Data {
        try JSONEncoder().encode(self)
    }

    public static func decodeFromJSON(_ data: Data) throws -> Pantry {
        try JSONDecoder().decode(Pantry.self, from: data)
    }
}
