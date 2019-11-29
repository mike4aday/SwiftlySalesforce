//
//  Salesforce+Image.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation
import UIKit
import Combine

public extension Salesforce {
    
    /// Asynchronously retrieves an image at the given URL.
    /// - Parameter url: Absolute URL of image, or path to image relative to the user's instance URL
    /// - Parameter config: Request configuration options
    /// - Returns: Publisher of a UIImage
    /// - Note: Use this method to fetch only small images, e.g. thumbnail-size images at Account.PhotoUrl, Contact.PhotoUrl, or Lead.PhotoUrl.
    func fetchImage(url: URL, config: RequestConfig = .shared) -> AnyPublisher<UIImage, Error> {
        let endpoint = Endpoint.smallFile(url: url, mimeType: "image/*")
        let pub: AnyPublisher<Data, Error> = request(requestConvertible: endpoint, config: config)
        return pub
        .receive(on: DispatchQueue.global(qos: .userInteractive))
        .tryMap { (data) -> UIImage in
            guard let img = UIImage(data: data) else {
                throw SalesforceError.invalidResponse
            }
            return img
        }
        .eraseToAnyPublisher()
    }
}
