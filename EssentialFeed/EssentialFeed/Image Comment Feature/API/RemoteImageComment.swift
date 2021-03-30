//
//  RemoteImageComment.swift
//  EssentialFeed
//
//  Created by Thiago Penna on 30/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteImageCommentRootObject: Decodable {
	let items: [RemoteImageComment]
}

struct RemoteImageComment: Decodable {
	let id: UUID
	let message: String
	let createdAt: Date
	let author: Author
	
	struct Author: Decodable {
		let username: String
	}
	
	enum CodingKeys: String, CodingKey {
		case id
		case message
		case createdAt = "created_at"
		case author
	}
}
