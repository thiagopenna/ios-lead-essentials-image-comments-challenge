//
//  ImageCommentPresenter.swift
//  EssentialFeed
//
//  Created by Thiago Penna on 27/04/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

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
