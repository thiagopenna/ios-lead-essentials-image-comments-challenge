//
//  RemoteImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Thiago Penna on 29/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteImageCommentLoader {
	public typealias Result = Swift.Result<[ImageComment], Swift.Error>
	
	private let client: HTTPClient
	private let baseURL: URL
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(client: HTTPClient, baseURL: URL) {
		self.client = client
		self.baseURL = baseURL
	}
		
	public func load(with imageId: UUID, completion: @escaping (Result) -> Void) {
		client.get(from: baseURL.appendingImageCommentURL(for: imageId)) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				completion(RemoteImageCommentLoader.map(data, from: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let comments = try ImageCommentMapper.map(data, from: response)
			return .success(comments.toModels())
		} catch {
			return .failure(error)
		}
	}
}

private extension Array where Element == RemoteImageComment {
	func toModels() -> [ImageComment] {
		return map { ImageComment(id: $0.id, message: $0.message, creationDate: $0.createdAt, author: ImageComment.Author(username: $0.author.username)) }
	}
}

private extension URL {
	func appendingImageCommentURL(for imageId: UUID) -> URL {
		return self
			.appendingPathComponent("image")
			.appendingPathComponent(imageId.uuidString)
			.appendingPathComponent("comments")
	}
}
