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
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(client: HTTPClient, baseURL: URL) {
		self.client = client
		self.baseURL = baseURL
	}
		
	public func load(with imageId: UUID, completion: @escaping (Result) -> Void) {
		client.get(from: baseURL.appendingImageCommentURL(for: imageId)) { result in
			switch result {
			case .success:
				completion(.failure(.invalidData))
			case .failure:
				completion(.failure(.connectivity))
			}
		}
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