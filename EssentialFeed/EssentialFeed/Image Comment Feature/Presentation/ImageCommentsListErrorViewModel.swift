//
//  ImageCommentsListErrorViewModel.swift
//  EssentialFeed
//
//  Created by Thiago Penna on 13/04/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentsListErrorViewModel {
	public let message: String?
	
	static var noError: ImageCommentsListErrorViewModel {
		return ImageCommentsListErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> ImageCommentsListErrorViewModel {
		return ImageCommentsListErrorViewModel(message: message)
	}
}
