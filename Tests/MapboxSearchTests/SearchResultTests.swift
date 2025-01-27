import XCTest
@testable import MapboxSearch

class SearchResultTests: XCTestCase {
    func testPlacemarkGeneration() throws {
        let resultStub = SearchResultStub(
            id: "unit-test-random",
            name: "Unit Test",
            matchingName: nil,
            resultType: .POI,
            coordinate: .init(latitude: 12, longitude: -35),
            metadata: .pizzaMetadata
        )
        
        XCTAssertEqual(resultStub.placemark.location?.coordinate.latitude, 12)
        XCTAssertEqual(resultStub.placemark.location?.coordinate.longitude, -35)
    }
}
