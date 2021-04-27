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
	
	func test_didLoad_displaysMultipleCommentsInOrder() {
		let (sut, view) = makeSUT()
		let now = Date().discardingMilliseconds
		let oneSecondAgo = now.adding(seconds: -1)
		let oneWeekAgo = now.adding(days: -7)
		let (comment1, _) = makeComment(id: UUID(), message: "A message", creationDate: oneSecondAgo, authorUsername: "An Author")
		let (comment2, _) = makeComment(id: UUID(), message: "Another message", creationDate: oneWeekAgo, authorUsername: "Another Author")
		
		sut.didLoad(comment1, referenceDate: now)
		sut.didLoad(comment2, referenceDate: now)
		
		XCTAssertEqual(view.messages.count, 2)
		XCTAssertEqual(view.messages.first, ImageCommentViewModel(message: "A message",
													  creationDate: "1 second ago",
													  authorUsername: "An Author"))
		XCTAssertEqual(view.messages.last, ImageCommentViewModel(message: "Another message",
													  creationDate: "1 week ago",
													  authorUsername: "Another Author"))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath,
						 line: UInt = #line) -> (sut: ImageCommentPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentPresenter(view: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private class ViewSpy: ImageCommentView {
		private(set) var messages = [ImageCommentViewModel]()
		
		func display(_ model: ImageCommentViewModel) {
			messages.append(model)
		}
	}
}
