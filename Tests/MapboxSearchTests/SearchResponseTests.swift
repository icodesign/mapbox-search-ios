import XCTest
@testable import MapboxSearch
import CwlPreconditionTesting

class SearchResponseTests: XCTestCase {
    func testResolvedAddressResult() throws {
        let coreResponse = CoreSearchResponseStub(id: 377,
                                              options: .sample1,
                                              result: .success([CoreSearchResultStub.makeAddress()]))
        let response = SearchResponse(coreResponse: coreResponse, associatedError: nil)
        
        let processedResponse = try response.process().get()
        XCTAssertTrue(processedResponse.suggestions.count == 1)
        XCTAssertEqual(processedResponse.results.first?.coordinate, .sample1)
    }

    func testFailedResponse() throws {
        let failedCoreResponse = CoreSearchResponseStub.failureSample
        let response = SearchResponse(coreResponse: failedCoreResponse, associatedError: nil)
        XCTAssertThrowsError(try response.process().get()) { error in
            if case let .generic(code, domain, message) = error as? SearchError {
                XCTAssertEqual(code, 500)
                XCTAssertEqual(domain, mapboxCoreSearchErrorDomain)
                XCTAssertEqual(message, "Server Internal error")
            } else {
                XCTFail("Expected \(SearchError.self) error type")
            }
        }
    }
    
    func testSuccessResponseWithAssociatedError() throws {
        let coreResponse = CoreSearchResponseStub.failureSample
        let nserror = NSError(domain: NSURLErrorDomain, code: 400, userInfo: [NSLocalizedDescriptionKey: "Bad Request"])
        let response = SearchResponse(coreResponse: coreResponse, associatedError: nserror)
        XCTAssertThrowsError(try response.process().get()) { error in
            if case let .generic(code, domain, message) = error as? SearchError {
                XCTAssertEqual(code, 400)
                XCTAssertEqual(domain, NSURLErrorDomain)
                XCTAssertEqual(message, nserror.description)
            } else {
                XCTFail("Expected \(SearchError.self) error type")
            }
        }
    }

    func testSuccessResponseWithZeroResults() throws {
        let coreResponse = CoreSearchResponseStub(id: 377, options: .sample1, result: .success([]))
        let response = SearchResponse(coreResponse: coreResponse, associatedError: nil)
        
        let processedResponse = try response.process().get()
        XCTAssertTrue(processedResponse.suggestions.isEmpty)
    }
    
    func testSuccessResponseWithSuggestionsOnly() throws {
        let expectedResults = CoreSearchResultStub.makeSuggestionsSet()
        let coreResponse = CoreSearchResponseStub(id: 377,
                                                  options: .sample1,
                                                  result: .success(expectedResults))
        let response = SearchResponse(coreResponse: coreResponse, associatedError: nil)
        
        let processedResponse = try response.process().get()
        XCTAssertTrue(processedResponse.results.isEmpty)
        XCTAssertEqual(processedResponse.suggestions.map({ $0.id }), expectedResults.map({ $0.id }))
    }
    
    func testSuccessResponseWithMixedResults() throws {
        let expectedResults = CoreSearchResultStub.makeMixedResultsSet()
        let coreResponse = CoreSearchResponseStub(id: 377,
                                                  options: .sample1,
                                                  result: .success(expectedResults))
        let response = SearchResponse(coreResponse: coreResponse, associatedError: nil)
        
        let processedResponse = try response.process().get()
        XCTAssertEqual(processedResponse.results.map({ $0.id }), expectedResults.filter({ $0.center != nil }).map({ $0.id }) )
        XCTAssertEqual(processedResponse.suggestions.map({ $0.id }), expectedResults.map({ $0.id }))
    }
    
    func testSuccessResponseWithResultsOnly() throws {
        let expectedResults = CoreSearchResultStub.makeCategoryResultsSet()
        let coreResponse = CoreSearchResponseStub(id: 377,
                                                  options: .sample1,
                                                  result: .success(expectedResults))
        let response = SearchResponse(coreResponse: coreResponse, associatedError: nil)
        
        let processedResponse = try response.process().get()
        XCTAssertEqual(processedResponse.results.map({ $0.id }), expectedResults.map({ $0.id }))
        XCTAssertEqual(processedResponse.suggestions.map({ $0.id }), expectedResults.map({ $0.id }))
    }
    
    func testSuccessResponseWithQueryOnly() throws {
        let expectedResults = [CoreSearchResultStub.makeSuggestionTypeQuery()]
        let coreResponse = CoreSearchResponseStub(id: 377,
                                                  options: .sample1,
                                                  result: .success(expectedResults))
        let response = SearchResponse(coreResponse: coreResponse, associatedError: nil)
        
        let processedResponse = try response.process().get()
        XCTAssertEqual(processedResponse.suggestions.map({ $0.id }), expectedResults.map({ $0.id }))
    }
    
    func testSuccessResponseWithUnsupportedType_UserRecord() throws {
        #if !arch(x86_64)
        throw XCTSkip("Unsupported architecture")
        #else

        let result = CoreSearchResultStub(id: "random-userRecord-type", type: .userRecord)
        let coreResponse = CoreSearchResponseStub(id: 377, options: .sample1, result: .success([result]))
        let response = SearchResponse(coreResponse: coreResponse, associatedError: nil)
        let assertionError = catchBadInstruction {
            let processedResponse = try? response.process().get()
            XCTAssert(processedResponse?.suggestions.isEmpty == true)
        }
        XCTAssertNotNil(assertionError)
        #endif
    }
}
