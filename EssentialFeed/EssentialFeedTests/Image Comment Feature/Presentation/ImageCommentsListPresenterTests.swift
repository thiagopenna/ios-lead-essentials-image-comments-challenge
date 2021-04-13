//
//  ImageCommentsListPresenterTests.swift
//  EssentialImageCommentTests
//
//  Created by Thiago Penna on 12/04/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

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
			.display(errorMessage: localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR")),
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
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsListPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
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
