//
//  Salesforce+UI.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2018. All rights reserved.
//


import Foundation
import PromiseKit

/// Enables interaction with the Salesforce User Interface API
/// See https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_get_started.htm

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
	
	/**
	Get records data and object metadata in a single call. See link for parameter descriptions and examples.
	- SeeAlso: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_resources_record_ui.htm
	*/
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
	
	/**
	Get defaults for cloning a record. See link for parameter descriptions and examples.
	- SeeAlso: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_resources_record_defaults_clone.htm
	*/
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
	
	/**
	Get defaults for creating a record. See link for parameter descriptions and examples.
	- SeeAlso: https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_resources_record_defaults_create.htm
	*/
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
}
