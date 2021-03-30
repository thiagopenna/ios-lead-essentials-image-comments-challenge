//
//  ImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Thiago Penna on 29/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentLoader {
	typealias Result = Swift.Result<[ImageComment], Error>
	
	func load(with imageId: UUID, completion: @escaping (Result) -> Void)
}
