//
//  ImageCommentViewModel.swift
//  EssentialFeed
//
//  Created by Thiago Penna on 27/04/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

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
