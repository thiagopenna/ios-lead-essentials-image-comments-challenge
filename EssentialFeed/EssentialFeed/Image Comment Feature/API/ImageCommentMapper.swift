//
//  ImageCommentMapper.swift
//  EssentialFeed
//
//  Created by Thiago Penna on 31/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

final class ImageCommentMapper {
	private struct Root: Decodable {
		let items: [RemoteImageComment]
	}
	
	static var decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}()

	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageComment] {
		
		guard response.is2xxOK, let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteImageCommentLoader.Error.invalidData
		}
		
		return root.items
	}
}
