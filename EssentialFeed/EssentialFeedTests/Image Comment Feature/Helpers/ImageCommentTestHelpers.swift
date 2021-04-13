//
//  ImageCommentTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Thiago Penna on 13/04/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

func makeComment(id: UUID, message: String, creationDate: Date, authorUsername: String) -> (comment: ImageComment, json: [String: Any]) {
	let comment = ImageComment(id: id, message: message, creationDate: creationDate.discardingMilliseconds, author: ImageComment.Author(username: authorUsername))
	
	let json = ["id": comment.id.uuidString,
				 "message": comment.message,
				 "created_at": comment.creationDate.iso8601string,
				 "author": ["username": comment.author.username]
	] as [String : Any]
	
	return (comment, json)
}

func uniqueImageComments() -> (items: [ImageComment], json: Data) {
	let (comment1, json1) = makeComment(id: UUID(), message: "a message", creationDate: Date(), authorUsername: "an author")
	let (comment2, json2) = makeComment(id: UUID(), message: "another message", creationDate: Date(), authorUsername: "another author")
	
	let items = [comment1, comment2]
	let json = makeItemsJSON([json1, json2])
	
	return (items, json)
}

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
	let json = ["items": items]
	return try! JSONSerialization.data(withJSONObject: json)
}
