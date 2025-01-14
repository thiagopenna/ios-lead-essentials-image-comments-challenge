//
//  Date+JsonHelpers.swift
//  EssentialFeedTests
//
//  Created by Thiago Penna on 31/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

extension Date {
	var iso8601string: String {
		return ISO8601DateFormatter().string(from: self)
	}
	
	var discardingMilliseconds: Date {
		return Date(timeIntervalSince1970: self.timeIntervalSince1970.rounded())
	}
	
	func adding(seconds: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .second, value: seconds, to: self)!
	}
	
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}
