//
//  RemoteImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Thiago Penna on 29/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteImageCommentLoader {
	public typealias Result = Swift.Result<[ImageComment], Error>
	
	private let client: HTTPClient
	private let baseURL: URL
	
	public init(client: HTTPClient, baseURL: URL) {
		self.client = client
		self.baseURL = baseURL
	}
		
	public func load(withImageId imageId: UUID, completion: @escaping (Result) -> Void) {
		client.get(from: baseURL.appendingImageCommentURL(for: imageId)) { _ in }
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
