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

public struct ImageCommentErrorViewModel {
	public let message: String?
	
	static var noError: ImageCommentErrorViewModel {
		return ImageCommentErrorViewModel(message: nil)
	}
}


public final class ImageCommentPresenter {
	private let errorView: ImageCommentErrorView
	
	init(errorView: ImageCommentErrorView) {
		self.errorView = errorView
	}
	
	public func didStartLoadingComments() {
		errorView.display(.noError)
	}
}
	
class ImageCommentPresenterTests: XCTestCase {
	func test_init_doesNotSendMessagesToView() {
		let view = ViewSpy()
		
		_ = ImageCommentPresenter(errorView: view)
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingComments_displaysNoErrorMessage() {
		let view = ViewSpy()
		let sut = ImageCommentPresenter(errorView: view)
		
		sut.didStartLoadingComments()
		
		XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
	}
	
	// MARK: - Helpers
	
	private class ViewSpy: ImageCommentErrorView {
		enum Message: Hashable {
			case display(errorMessage: String?)
		}
		
		private(set) var messages = [Message]()
		
		func display(_ viewModel: ImageCommentErrorViewModel) {
			messages.append(.display(errorMessage: viewModel.message))
		}
	}
}
