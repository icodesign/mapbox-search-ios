@testable import MapboxSearch
import MapboxCommon
import Foundation
import CoreLocation

class CoreSearchEngineStub {
    var accessToken: String
    let platformClient: CorePlatformClient
    let locationProvider: CoreLocationProvider?
    
    var searchResponse: CoreSearchResponseProtocol?
    
    var eventTemplate = """
                            {
                                "event": "__event_name",
                                "created": "2014-01-01T23:28:56.782Z",
                                "userAgent": "custom-user-agent",
                                "customField": "random-value"
                            }
                            """
    
    var callbackWrapper: (@escaping () -> Void) -> Void = { $0() }
    
    init(accessToken: String, client: CorePlatformClient, location: CoreLocationProvider?) {
        self.accessToken = accessToken
        self.platformClient = client
        self.locationProvider = location
    }
}

extension CoreSearchEngineStub: CoreSearchEngineProtocol {
    
    func setTileStore(_ tileStore: MapboxCommon.TileStore) {
        assertionFailure("Not Implemented")
    }
    
    func setTileStore(_ tileStore: MapboxCommon.TileStore, completion: (() -> Void)?) {
        assertionFailure("Not Implemented")
        completion?()
    }
    
    func setAccessTokenForToken(_ token: String) {
        accessToken = token
    }
    
    func createChildEngine() -> CoreSearchEngineProtocol {
        assertionFailure("Not Implemented")
        return self
    }
    
    func createUserLayer(_ layer: String, priority: Int32) -> CoreUserRecordsLayerProtocol {
        CoreUserRecordsLayerStub(name: layer)
    }
    func addUserLayer(_ layer: CoreUserRecordsLayerProtocol) {
    }
    
    func removeUserLayer(_ layer: CoreUserRecordsLayerProtocol) {
        assertionFailure("Not Implemented")
    }
    
    func search(forQuery query: String, categories: [String], options: CoreSearchOptions, completion: @escaping (CoreSearchResponseProtocol?) -> Void) {
        DispatchQueue.main.async {
            self.callbackWrapper {
                completion(self.searchResponse)
            }
        }
    }
    
    func nextSearch(for result: CoreSearchResultProtocol, with originalRequest: CoreRequestOptions, callback: @escaping (CoreSearchResponseProtocol?) -> Void) {
        DispatchQueue.main.async {
            self.callbackWrapper {
                callback(self.searchResponse)
            }
        }
    }
    
    func batchResolve(results: [CoreSearchResultProtocol], with originalRequest: CoreRequestOptions, callback: @escaping (CoreSearchResponseProtocol?) -> Void) {
        DispatchQueue.main.async {
            self.callbackWrapper {
                callback(self.searchResponse)
            }
        }
    }
    
    func onSelected(forRequest request: CoreRequestOptions, result: CoreSearchResultProtocol) {
        print("\(#function): No-op")
    }
    
    func createEventTemplate(forName name: String) -> String {
        return eventTemplate.replacingOccurrences(of: "__event_name", with: name)
    }
    
    func makeFeedbackEvent(request: CoreRequestOptions, result: CoreSearchResultProtocol?) throws -> String {
        let eventTemplate = """
                            {
                                "created": "2021-02-05T11:41:04+0300",
                                "endpoint": "https://api.mapbox.com/search/v1/",
                                "event": "search.feedback",
                                "language": ["\(result?.languages.first ?? "none")"],
                                "lat": 53.92068293258732,
                                "lng": 27.587735185708915,
                                "proximity":
                                    [\(request.options.proximity?.coordinate.longitude ?? -1),
                                     \(request.options.proximity?.coordinate.latitude ?? -1)],
                                "queryString": "\(request.query)",
                                "resultId": "\(result?.id ?? "nope")",
                                "resultIndex": \(result?.serverIndex ?? -1),
                                "schema": "search.feedback-2.1",
                                "selectedItemName":"\(result?.names.first ?? "")",
                                "sessionIdentifier": "\(UUID().uuidString)",
                                "userAgent": "search-sdk-ios"
                            }
                            """
        return eventTemplate
    }
    
    func reverseGeocoding(for options: CoreReverseGeoOptions, completion: @escaping (CoreSearchResponseProtocol?) -> Void) {
        DispatchQueue.main.async {
            self.callbackWrapper {
                completion(self.searchResponse)
            }
        }
    }
    
    func addOfflineRegion(path: String, maps: [String], boundary: String) -> Result<Void, AddOfflineRegionError> {
        return .success(())
    }
    
    func searchOffline(query: String, categories: [String], options: CoreSearchOptions, completion: @escaping (CoreSearchResponseProtocol?) -> Void) {
        search(forQuery: query, categories: categories, options: options, completion: completion)
    }
    
    func getOfflineAddress(street: String, proximity: CLLocationCoordinate2D, radius: Double, completion: @escaping (CoreSearchResponseProtocol?) -> Void) {
        DispatchQueue.main.async {
            self.callbackWrapper {
                completion(self.searchResponse)
            }
        }
    }
    
    func retrieveOffline(for result: CoreSearchResultProtocol, with originalRequest: CoreRequestOptions, callback: @escaping (CoreSearchResponseProtocol?) -> Void) {
        nextSearch(for: result, with: originalRequest, callback: callback)
    }
    
    func reverseGeocodingOffline(for options: CoreReverseGeoOptions, completion: @escaping (CoreSearchResponseProtocol?) -> Void) {
        reverseGeocoding(for: options, completion: completion)
    }
}
