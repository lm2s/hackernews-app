    //
//  TheNewsTests.swift
//  TheNewsTests
//
//  Created by Luís Silva on 02/12/2020.
//

import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import TheNews

class TheNewsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testHackerNewsAPIFetchTopPosts() {
        let expectation = XCTestExpectation(description: "testHackerNewsAPIFetchTopPosts")

        stub(condition: isHost("hacker-news.firebaseio.com") && isPath("/v0/topstories.json")) { request in
            let path = OHHTTPStubs.OHPathForFile("topstories.json", type(of: self))!
            return OHHTTPStubs.HTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        [25275637, 25273907, 25271791].forEach { itemId in
            stub(condition: isHost("hacker-news.firebaseio.com") && isPath("/v0/item/\(itemId).json")) { request in
                let path = OHHTTPStubs.OHPathForFile("item_\(itemId).json", type(of: self))!
                return OHHTTPStubs.HTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type": "application/json"])
            }
        }

        let networkService = NetworkService(baseURL: URL(string: "https://hacker-news.firebaseio.com/v0")!)
        let persistenceController = PersistenceController(inMemory: true)
        let hackerNewsAPI = HackerNewsAPI(networkService: networkService, persistenceController: persistenceController)

        hackerNewsAPI.fetchTopPosts { result in
            switch result {
            case let .success(posts):
                XCTAssert(posts.count == 3)

                XCTAssert(posts[0].id == 25275637)
                XCTAssert(posts[0].title == "Amnesia – Data anonymization made easy")
                XCTAssert(posts[0].url.absoluteString == "https://amnesia.openaire.eu/")
                XCTAssert(posts[0].numberOfComments == 6)
                XCTAssert(posts[0].score == 39)

            case let .failure(error):
                XCTFail(error.localizedDescription)
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }
}
