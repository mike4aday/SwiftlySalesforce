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
	
	public func recordsAndMetadata<T: Decodable>(
		recordIds: [String],
		childRelationships: [String]? = nil,
		formFactor: FormFactor? = nil,
		layoutTypes: [LayoutType]? = nil,
		modes: [Mode]? = nil,
		optionalFields: [String]? = nil,
		pageSize: Int? = nil,
		options: Options = []) -> Promise<T> {
		
		let resource = UIResource.records(
			recordIds: recordIds,
			childRelationships: childRelationships,
			formFactor: formFactor?.rawValue,
			layoutTypes: layoutTypes?.map { $0.rawValue },
			modes: modes?.map { $0.rawValue },
			optionalFields: optionalFields,
			pageSize: pageSize,
			version: config.version)
		return dataTask(with: resource, options: options)
	}
	
	public func defaultsForCloning<T: Decodable>(
		recordId: String,
		formFactor: FormFactor? = nil,
		optionalFields: [String]? = nil,
		recordTypeId: String? = nil,
		options: Options = []) -> Promise<T> {
		
		let resource = UIResource.defaultsForCloning(
			recordId: recordId,
			formFactor: formFactor?.rawValue,
			optionalFields: optionalFields,
			recordTypeId: recordTypeId,
			version: config.version)
		return dataTask(with: resource, options: options)
	}
	
	public func defaultsForCreating<T: Decodable>(
		objectApiName: String,
		formFactor: FormFactor? = nil,
		optionalFields: [String]? = nil,
		recordTypeId: String? = nil,
		options: Options = []) -> Promise<T> {
		
		let resource = UIResource.defaultsForCreating(
			objectApiName: objectApiName,
			formFactor: formFactor?.rawValue,
			optionalFields: optionalFields,
			recordTypeId: recordTypeId,
			version: config.version)
		return dataTask(with: resource, options: options)
	}
	
	public func picklistValues<T: Decodable>(
		objectApiName: String,
		recordTypeId: String,
		options: Options) -> Promise<T> {
		
		let resource = UIResource.picklistValues(objectApiName: objectApiName, recordTypeId: recordTypeId, version: config.version)
		return dataTask(with: resource, options: options)
	}
}
