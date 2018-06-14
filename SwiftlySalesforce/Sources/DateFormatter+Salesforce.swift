//
//  DateFormatter+Salesforce.swift
//
//  Created by Michael Epstein on 6/12/18.
//

import Foundation

public extension DateFormatter {
	
	// Adapted from http://codingventures.com/articles/Dating-Swift/
	
	public static let salesforceDateTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}()
	
	public static let salesforceDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}()
}
