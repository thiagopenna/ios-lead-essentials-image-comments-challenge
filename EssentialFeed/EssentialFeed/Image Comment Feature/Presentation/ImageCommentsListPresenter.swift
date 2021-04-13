//
//  ImageCommentsListPresenter.swift
//  EssentialFeed
//
//  Created by Thiago Penna on 13/04/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsListErrorView {
	func display(_ viewModel: ImageCommentsListErrorViewModel)
}

public protocol ImageCommentsListLoadingView {
	func display(_ viewModel: ImageCommentsListLoadingViewModel)
}

public protocol ImageCommentsListView {
	func display(_ viewModel: ImageCommentsListViewModel)
}

public final class ImageCommentsListPresenter {
	private let errorView: ImageCommentsListErrorView
	private let loadingView: ImageCommentsListLoadingView
	private let commentsView: ImageCommentsListView
	
	private var imageCommentsLoadError: String {
		return NSLocalizedString("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR",
			 tableName: "ImageComments",
			 bundle: Bundle(for: ImageCommentsListPresenter.self),
			 comment: "Error message displayed when we can't load the image comments from the server")
	}
		
	public init(errorView: ImageCommentsListErrorView, loadingView: ImageCommentsListLoadingView, commentsView: ImageCommentsListView) {
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
		errorView.display(.error(message: imageCommentsLoadError))
	}
}
