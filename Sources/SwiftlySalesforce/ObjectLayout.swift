//
//  SFDCLayout.swift
//  SFDC Tool
//
//  Created by Alexey Malashin on 28.05.2020.
//  Copyright © 2020 Alexey Malashin. All rights reserved.
//

import Foundation

public struct ObjectPicklistValue: Codable {
    var label: String
    var validFor: String?
    var value: String
}

public struct ObjectLayoutComponentDetails: Codable {
    var inlineHelpText: String?
    var label: String
    var name: String
    var controllerName: String?
    var picklistValues: [ObjectPicklistValue]
}

public struct ObjectLayoutComponent: Codable {
    var type: String
    var value: String?
    var details: ObjectLayoutComponentDetails?
}

public struct ObjectLayoutItem: Codable {
    var label: String
    var required: Bool
    var layoutComponents: [ObjectLayoutComponent]
}

public struct ObjectLayoutRow: Codable {
    var numItems: Int
    var layoutItems: [ObjectLayoutItem]
}

public struct ObjectLayoutSection: Codable {
    var layoutSectionId: String
    var parentLayoutId: String
    var rows: Int
    var heading: String
    var columns: Int
    var layoutRows: [ObjectLayoutRow]
}

public struct ObjectLayout: Codable {
    var id: String
    var detailLayoutSections: [ObjectLayoutSection]
}
