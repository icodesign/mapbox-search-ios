@testable import MapboxSearch
import CoreLocation

struct TestDataProviderRecord: IndexableRecord, SearchResult {
    var type: SearchResultType
    var id: String = UUID().uuidString
    var name: String
    var matchingName: String?
    var coordinate: CLLocationCoordinate2D
    var iconName: String?
    var categories: [String]?
    var routablePoints: [RoutablePoint]?
    var address: Address?
    var additionalTokens: Set<String>?
    var estimatedTime: Measurement<UnitDuration>?
    var metadata: SearchResultMetadata?
    var descriptionText: String?

    static func testData(count: Int) -> [TestDataProviderRecord] {
        var results = [TestDataProviderRecord]()
        for index in 0...count {
            let record = TestDataProviderRecord(
                type: .POI,
                name: "name_\(index)",
                coordinate: CLLocationCoordinate2D(latitude: 53.89, longitude: 27.55)
            )
            results.append(record)
        }
        return results
    }
}
