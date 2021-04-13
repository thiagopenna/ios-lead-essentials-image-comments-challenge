//
//  ImageCommentsListPresenterTests.swift
//  EssentialImageCommentTests
//
//  Created by Thiago Penna on 12/04/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

public protocol ImageCommentsListErrorView {
	func display(_ viewModel: ImageCommentsListErrorViewModel)
}

public protocol ImageCommentsListLoadingView {
	func display(_ viewModel: ImageCommentsListLoadingViewModel)
}

public protocol ImageCommentsListView {
	func display(_ viewModel: ImageCommentsListViewModel)
}

public struct ImageCommentsListErrorViewModel {
	public let message: String?
	
	static var noError: ImageCommentsListErrorViewModel {
		return ImageCommentsListErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> ImageCommentsListErrorViewModel {
		return ImageCommentsListErrorViewModel(message: message)
	}
}

public struct ImageCommentsListLoadingViewModel {
	public let isLoading: Bool
}

public struct ImageCommentsListViewModel {
	public let comments: [ImageComment]
}

public final class ImageCommentsListPresenter {
	private let errorView: ImageCommentsListErrorView
	private let loadingView: ImageCommentsListLoadingView
	private let commentsView: ImageCommentsListView
	
	init(errorView: ImageCommentsListErrorView, loadingView: ImageCommentsListLoadingView, commentsView: ImageCommentsListView) {
		self.errorView = errorView
		self.loadingView = loadingView
		self.commentsView = commentsView
	}
	
	public func didStartLoadingComments() {
		errorView.display(.noError)
		loadingView.display(ImageCommentsListLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingComments(with comments: [ImageComment]) {
		loadingView.display(ImageCommentsListLoadingViewModel(isLoading: false))
		commentsView.display(ImageCommentsListViewModel(comments: comments))
	}
	
	public func didFinishLoadingComments(with error: Error) {
		loadingView.display(ImageCommentsListLoadingViewModel(isLoading: false))
		errorView.display(.error(message: "Error"))
	}
}
	
class ImageCommentsListPresenterTests: XCTestCase {
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
		let (comments, _) = uniqueImageComments()
		
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
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsListPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsListPresenter(errorView: view, loadingView: view, commentsView: view)
		trackForMemoryLeaks(view)
		trackForMemoryLeaks(sut)
		return (sut, view)
	}
	
	private class ViewSpy: ImageCommentsListErrorView, ImageCommentsListLoadingView, ImageCommentsListView {
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(comments: [ImageComment])
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: ImageCommentsListErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: ImageCommentsListLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: ImageCommentsListViewModel) {
			messages.insert(.display(comments: viewModel.comments))
		}
		
	}
}
