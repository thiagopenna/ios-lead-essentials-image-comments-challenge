//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Thiago Penna on 29/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment {
	public let id: UUID
	public let message: String
	public let creationDate: Date
	public let author: Author
	
	public struct Author {
		public let username: String
	}
}
