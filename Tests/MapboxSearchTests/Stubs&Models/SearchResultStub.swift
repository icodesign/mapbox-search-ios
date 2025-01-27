@testable import MapboxSearch
import CoreLocation


class SearchResultStub: SearchResult {
    init(
        id: String,
        categories: [String]? = nil,
        name: String,
        matchingName: String?,
        iconName: String? = nil,
        resultType: SearchResultType,
        routablePoints: [RoutablePoint]? = nil,
        coordinate: CLLocationCoordinate2DCodable,
        address: Address? = nil,
        metadata: SearchResultMetadata?,
        dataLayerIdentifier: String = "unit-test-stub"
    ) {
        self.id = id
        self.categories = categories
        self.name = name
        self.matchingName = matchingName
        self.iconName = iconName
        self.type = resultType
        self.routablePoints = routablePoints
        self.coordinateCodable = coordinate
        self.address = address
        self.metadata = metadata
        self.dataLayerIdentifier = dataLayerIdentifier
    }
    
    var dataLayerIdentifier: String
    
    var id: String
    var categories: [String]?
    var name: String
    var matchingName: String?
    var iconName: String?
    var type: SearchResultType
    var routablePoints: [RoutablePoint]?
    var estimatedTime: Measurement<UnitDuration>?
    var metadata: SearchResultMetadata?
    var coordinate: CLLocationCoordinate2D {
        get {
            coordinateCodable.coordinates
        }
        set {
            coordinateCodable = .init(newValue)
        }
    }
    
    var coordinateCodable: CLLocationCoordinate2DCodable
    var address: Address?
    var descriptionText: String?
}
