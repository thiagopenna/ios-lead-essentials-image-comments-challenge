//
//  ImageCommentPresenterTests.swift
//  EssentialImageCommentTests
//
//  Created by Thiago Penna on 12/04/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

public protocol ImageCommentErrorView {
	func display(_ viewModel: ImageCommentErrorViewModel)
}

public protocol ImageCommentLoadingView {
	func display(_ viewModel: ImageCommentLoadingViewModel)
}

public protocol ImageCommentsView {
	func display(_ viewModel: ImageCommentsViewModel)
}

public struct ImageCommentErrorViewModel {
	public let message: String?
	
	static var noError: ImageCommentErrorViewModel {
		return ImageCommentErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> ImageCommentErrorViewModel {
		return ImageCommentErrorViewModel(message: message)
	}
}

public struct ImageCommentLoadingViewModel {
	public let isLoading: Bool
}

public struct ImageCommentsViewModel {
	public let comments: [ImageComment]
}

public final class ImageCommentPresenter {
	private let errorView: ImageCommentErrorView
	private let loadingView: ImageCommentLoadingView
	private let commentsView: ImageCommentsView
	
	init(errorView: ImageCommentErrorView, loadingView: ImageCommentLoadingView, commentsView: ImageCommentsView) {
		self.errorView = errorView
		self.loadingView = loadingView
		self.commentsView = commentsView
	}
	
	public func didStartLoadingComments() {
		errorView.display(.noError)
		loadingView.display(ImageCommentLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingComments(with comments: [ImageComment]) {
		loadingView.display(ImageCommentLoadingViewModel(isLoading: false))
		commentsView.display(ImageCommentsViewModel(comments: comments))
	}
	
	public func didFinishLoadingComments(with error: Error) {
		loadingView.display(ImageCommentLoadingViewModel(isLoading: false))
		errorView.display(.error(message: "Error"))
	}
}
	
class ImageCommentPresenterTests: XCTestCase {
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingComments_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingComments()
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: .none),
			.display(isLoading: true)
		])
	}
	
	func test_didFinishLoadingComments_displaysCommentsAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		let comment1 = ImageComment(id: UUID(), message: "A message", creationDate: Date(), author: ImageComment.Author(username: "An Author"))
		let comment2 = ImageComment(id: UUID(), message: "Another message", creationDate: Date(), author: ImageComment.Author(username: "Another Author"))
		let comments = [comment1, comment2]

		sut.didFinishLoadingComments(with: comments)

		XCTAssertEqual(view.messages, [
			.display(comments: comments),
			.display(isLoading: false)
		])
	}
	
	func test_didFinishLoadingCommentsWithError_displaysErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingComments(with: anyNSError())

		XCTAssertEqual(view.messages, [
			.display(errorMessage: "Error"),
			.display(isLoading: false)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentPresenter(errorView: view, loadingView: view, commentsView: view)
		trackForMemoryLeaks(view)
		trackForMemoryLeaks(sut)
		return (sut, view)
	}
	
	private class ViewSpy: ImageCommentErrorView, ImageCommentLoadingView, ImageCommentsView {
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(comments: [ImageComment])
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: ImageCommentErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: ImageCommentLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: ImageCommentsViewModel) {
			messages.insert(.display(comments: viewModel.comments))
		}
		
	}
}
