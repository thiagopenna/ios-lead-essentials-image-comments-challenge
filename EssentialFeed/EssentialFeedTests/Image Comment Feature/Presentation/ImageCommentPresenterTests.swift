//
//  ImageCommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Thiago Penna on 12/04/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

public final class ImageCommentPresenter {
	init(view: Any) {
		
	}
}
	
class ImageCommentPresenterTests: XCTestCase {
	func test_init_doesNotSendMessagesToView() {
		let view = ViewSpy()
		
		_ = ImageCommentPresenter(view: view)
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	private class ViewSpy {
		private(set) var messages = [Any]()
	}
}
