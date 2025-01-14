//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Thiago Penna on 29/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

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
		
		expect(sut, toCompleteWith: .failure(RemoteImageCommentLoader.Error.connectivity)) {
			client.complete(with: NSError(domain: "Test", code: 0))
		}
	}
	
	func test_load_deliversErrorOnNon2xxHTTPResponse() {
		let (sut, client) = makeSUT()
		let codes = [199, 300, 400, 500]
		
		codes.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .failure(RemoteImageCommentLoader.Error.invalidData)) {
				client.complete(withStatusCode: code, data: Data(), at: index)
			}
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(RemoteImageCommentLoader.Error.invalidData), when: {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		})
	}
	
	func test_load_deliversSuccessOn2xxHTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		let codes = [200, 201, 204, 299]
		
		codes.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success([]), when: {
				let emptyListJSON = makeItemsJSON([])
				client.complete(withStatusCode: code, data: emptyListJSON, at: index)
			})
		}
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
		let (items, json) = uniqueImageComments()
		
		expect(sut, toCompleteWith: .success(items), when: {
			client.complete(withStatusCode: 200, data: json)
		})
	}
	
	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let baseURL = URL(string: "http://any-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteImageCommentLoader? = RemoteImageCommentLoader(client: client, baseURL: baseURL)
		
		var capturedResults = [RemoteImageCommentLoader.Result]()
		sut?.load(with: UUID()) { capturedResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: makeItemsJSON([]))
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(baseURL: URL = URL(string: "https://base-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentLoader(client: client, baseURL: baseURL)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func expectedURL(for baseURL: URL, imageId: UUID) -> URL {
		return baseURL.appendingPathComponent("image/\(imageId)/comments")
	}
	
	private func expect(_ sut: RemoteImageCommentLoader, toCompleteWith expectedResult: RemoteImageCommentLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load(with: UUID()) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
				
			case let (.failure(receivedError as RemoteImageCommentLoader.Error), .failure(expectedError as RemoteImageCommentLoader.Error)):
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
