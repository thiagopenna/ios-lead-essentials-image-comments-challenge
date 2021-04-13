//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Thiago Penna on 29/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Hashable {
	public let id: UUID
	public let message: String
	public let creationDate: Date
	public let author: Author
	
	public struct Author: Hashable {
		public let username: String
		
		public init(username: String) {
			self.username = username
		}
	}
	
	public init(id: UUID, message: String, creationDate: Date, author: Author) {
		self.id = id
		self.message = message
		self.creationDate = creationDate
		self.author = author
	}
}
