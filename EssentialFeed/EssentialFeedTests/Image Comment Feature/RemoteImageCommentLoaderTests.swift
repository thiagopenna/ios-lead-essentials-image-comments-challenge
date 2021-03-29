//
//  RemoteImageCommentLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Thiago Penna on 29/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteImageCommentLoaderTests: XCTestCase {

	func test_init_doesNotRequestDataFromURL() {
		let client = HTTPClientSpy()
		let _ = RemoteImageCommentLoader(client: client)
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
}
