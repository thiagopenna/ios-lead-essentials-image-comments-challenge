//
//  RemoteImageCommentLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Thiago Penna on 29/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialFeed

class RemoteImageCommentLoaderTests: XCTestCase {

	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let baseURL = URL(string: "https://a-given-base-url.com")!
		let imageId = UUID()
		let (sut, client) = makeSUT(baseURL: baseURL)
		
		sut.load(with: imageId) { _ in }
		
		XCTAssertEqual(client.requestedURLs.first, expectedURL(for: baseURL, imageId: imageId))
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let baseURL = URL(string: "https://a-given-base-url.com")!
		let imageId = UUID()
		let (sut, client) = makeSUT(baseURL: baseURL)
		
		sut.load(with: imageId) { _ in }
		sut.load(with: imageId) { _ in }
		
		let expectedURL = self.expectedURL(for: baseURL, imageId: imageId)
		XCTAssertEqual(client.requestedURLs, [expectedURL, expectedURL])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(.connectivity)) {
			client.complete(with: NSError(domain: "Test", code: 0))
		}
	}
	
	func test_load_deliversErrorOnNon2xxHTTPResponse() {
		let (sut, client) = makeSUT()
		let codes = [199, 300, 400, 500]
		
		codes.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .failure(.invalidData)) {
				client.complete(withStatusCode: code, data: Data(), at: index)
			}
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(.invalidData), when: {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		})
	}
	
	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .success([]), when: {
			let emptyListJSON = makeItemsJSON([])
			client.complete(withStatusCode: 200, data: emptyListJSON)
		})
	}
	
	func test_load_deliversCommentsOn200HTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()
		
		let comment1 = ImageComment(id: UUID(), message: "a message", creationDate: Date().discardingMilliseconds, author: ImageComment.Author(username: "an author"))
		
		let json1 = ["id": comment1.id.uuidString,
					 "message": comment1.message,
					 "created_at": comment1.creationDate.iso8601string,
					 "author": ["username": comment1.author.username]
		] as [String : Any]
		
		let comment2 = ImageComment(id: UUID(), message: "another message", creationDate: Date().discardingMilliseconds, author: ImageComment.Author(username: "another author"))
		
		let json2 = ["id": comment2.id.uuidString,
					 "message": comment2.message,
					 "created_at": comment2.creationDate.iso8601string,
					 "author": ["username": comment2.author.username]
		] as [String : Any]
		
		let items = [comment1, comment2]
		
		expect(sut, toCompleteWith: .success(items), when: {
			let json = makeItemsJSON([json1, json2])
			client.complete(withStatusCode: 200, data: json)
		})
	}
	
	// MARK: - Helpers
	
	private func makeSUT(baseURL: URL = URL(string: "https://base-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentLoader(client: client, baseURL: baseURL)
		return (sut, client)
	}
	
	private func expectedURL(for baseURL: URL, imageId: UUID) -> URL {
		return baseURL.appendingPathComponent("image/\(imageId)/comments")
	}
	
	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func expect(_ sut: RemoteImageCommentLoader, toCompleteWith expectedResult: RemoteImageCommentLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load(with: UUID()) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
				
			case let (.failure(receivedError), .failure(expectedError)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
				
			default:
				XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		action()
		wait(for: [exp], timeout: 1.0)
	}
}

private extension Date {
	var iso8601string: String {
		return ISO8601DateFormatter().string(from: self)
	}
	
	var discardingMilliseconds: Date {
		return Date(timeIntervalSince1970: self.timeIntervalSince1970.rounded())
	}
}
