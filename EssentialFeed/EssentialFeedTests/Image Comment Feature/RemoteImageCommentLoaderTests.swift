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
		
		let exp = expectation(description: "Wait for load completion")
		sut.load(with: UUID()) { result in
			if case let .failure(receivedError) = result {
				XCTAssertEqual(receivedError, .connectivity)
			} else {
				XCTFail("Expected connectivity error, got \(result) instead")
			}
			exp.fulfill()
		}
		
		client.complete(with: NSError(domain: "Test", code: 0))
		wait(for: [exp], timeout: 1.0)
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
	
}
