//
//  Salesforce+UI.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//


import Foundation
import PromiseKit

public extension Salesforce {
	
	public enum FormFactor: String {
		case large = "Large"
		case medium = "Medium"
		case small = "Small"
	}
	
	public enum LayoutType: String {
		case compact = "Compact"
		case full = "Full"
	}
	
	public enum Mode: String {
		case create = "Create"
		case edit = "Edit"
		case view = "View"
	}
	
	public func getRecordsAndMetadata<T: Decodable>(
		ids: [String],
		childRelationships: [String]?,
		formFactor: FormFactor?,
		layoutTypes: [LayoutType]?,
		modes: [Mode]?,
		optionalFields: [String]?,
		pageSize: Int?,
		options: Options) -> Promise<T> {
		
		let resource = UIResource.records(
			ids: ids,
			childRelationships: childRelationships,
			formFactor: formFactor?.rawValue,
			layoutTypes: layoutTypes?.map { $0.rawValue },
			modes: modes?.map { $0.rawValue },
			optionalFields: optionalFields,
			pageSize: pageSize,
			version: config.version)
		return dataTask(resource: resource, options: options)
	}
	
	public func getDefaultsForCloning<T: Decodable>(
		id: String,
		formFactor: FormFactor?,
		optionalFields: [String]?,
		recordTypeID: String?,
		options: Options) -> Promise<T> {
		
		let resource = UIResource.defaultsForCloning(
			id: id,
			formFactor: formFactor?.rawValue,
			optionalFields: optionalFields,
			recordTypeID: recordTypeID,
			version: config.version)
		return dataTask(resource: resource, options: options)
	}
	
	public func getDefaultsForCreating<T: Decodable>(
		type: String,
		formFactor: FormFactor?,
		optionalFields: [String]?,
		recordTypeID: String?,
		options: Options) -> Promise<T> {
		
		let resource = UIResource.defaultsForCreating(
			type: type,
			formFactor: formFactor?.rawValue,
			optionalFields: optionalFields,
			recordTypeID: recordTypeID,
			version: config.version)
		return dataTask(resource: resource, options: options)
	}
}
