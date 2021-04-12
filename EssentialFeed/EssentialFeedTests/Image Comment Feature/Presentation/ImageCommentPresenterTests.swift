//
//  ImageCommentPresenterTests.swift
//  EssentialImageCommentTests
//
//  Created by Thiago Penna on 12/04/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

public protocol ImageCommentErrorView {
	func display(_ viewModel: ImageCommentErrorViewModel)
}

public protocol ImageCommentLoadingView {
	func display(_ viewModel: ImageCommentLoadingViewModel)
}

public struct ImageCommentErrorViewModel {
	public let message: String?
	
	static var noError: ImageCommentErrorViewModel {
		return ImageCommentErrorViewModel(message: nil)
	}
}

public struct ImageCommentLoadingViewModel {
	public let isLoading: Bool
}

public final class ImageCommentPresenter {
	private let errorView: ImageCommentErrorView
	private let loadingView: ImageCommentLoadingView
	
	init(errorView: ImageCommentErrorView, loadingView: ImageCommentLoadingView) {
		self.errorView = errorView
		self.loadingView = loadingView
	}
	
	public func didStartLoadingComments() {
		errorView.display(.noError)
		loadingView.display(ImageCommentLoadingViewModel(isLoading: true))
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
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentPresenter(errorView: view, loadingView: view)
		trackForMemoryLeaks(view)
		trackForMemoryLeaks(sut)
		return (sut, view)
	}
	
	private class ViewSpy: ImageCommentErrorView, ImageCommentLoadingView {
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
		}
		
		private(set) var messages = [Message]()
		
		func display(_ viewModel: ImageCommentErrorViewModel) {
			messages.append(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: ImageCommentLoadingViewModel) {
			messages.append(.display(isLoading: viewModel.isLoading))
		}
	}
}
