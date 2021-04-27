//
//  ImageCommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Thiago Penna on 13/04/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

public protocol ImageCommentView {
	func display(_ model: ImageCommentViewModel)
}

public struct ImageCommentViewModel: Hashable {
	public let message: String
	public let creationDate: String
	public let authorUsername: String
	
	public init(message: String, creationDate: String, authorUsername: String) {
		self.message = message
		self.creationDate = creationDate
		self.authorUsername = authorUsername
	}
}

public final class ImageCommentPresenter {
	private let view: ImageCommentView
	
	public init(view: ImageCommentView) {
		self.view = view
	}
	
	public func didLoad(_ comment: ImageComment, referenceDate: Date = Date()) {
		let formatter = RelativeDateTimeFormatter()
		let creationDateText = formatter.localizedString(for: comment.creationDate, relativeTo: referenceDate)
		
		view.display(ImageCommentViewModel(message: comment.message,
										   creationDate: creationDateText,
										   authorUsername: comment.author.username))
	}
}

class ImageCommentPresenterTests: XCTestCase {
	
	func test_didLoad_displaysWithRecentMessage() {
		let view = ViewSpy()
		let sut = ImageCommentPresenter(view: view)
		let now = Date()
		let oneSecondAgo = now.adding(seconds: -1)
		let (comment, _) = makeComment(id: UUID(), message: "A message", creationDate: oneSecondAgo, authorUsername: "An Author")
		
		sut.didLoad(comment, referenceDate: now)
		
		XCTAssertEqual(view.messages.count, 1)
		let message = view.messages.first
		XCTAssertEqual(message?.message, "A message")
		XCTAssertEqual(message?.creationDate, "1 second ago")
		XCTAssertEqual(message?.authorUsername, "An Author")
	}
	
	// MARK: - Helpers
	
	private class ViewSpy: ImageCommentView {
		private(set) var messages = Set<ImageCommentViewModel>()
		
		func display(_ model: ImageCommentViewModel) {
			messages.insert(model)
		}
	}
}
