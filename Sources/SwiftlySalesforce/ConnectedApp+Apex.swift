/*
"Swiftly Salesforce: the Swift-est way to build iOS apps that connect to Salesforce"
For more information and license see: https://www.github.com/mike4aday/SwiftlySalesforce
Copyright (c) 2021. All rights reserved.
*/

import Foundation
import Combine

public extension ConnectedApp {
    
    /// Represents a call to an Apex class exposed as a REST service.
    ///
    /// You can expose your Apex class and methods so that external applications can access your code and your application through the REST architecture. This is done by defining your Apex class with the @RestResource annotation to expose it as a REST resource. Similarly, add annotations to your methods to expose them through REST. For example, you can add the @HttpGet annotation to your method to expose it as a REST resource that can be called by an HTTP GET request.
    /// - Parameters:
    ///   - method: Name of the Apex method to call.
    ///   - namespace: Managed package namespace, if any. Optional.
    ///   - relativePath: Path to the Apex REST service, as defined in the `urlMapping` of the `@RestResource` annotation on the target class.
    ///   - queryItems: Optional query items to include in the request.
    ///   - headers: Optional `HTTP` headers to include in the request.
    ///   - body: Request body for a `POST` , `PATCH` or `PUT`  request.
    ///   - validator: Validator to validate the server response.
    ///   - decoder: JSON decoder to use to decode the results.
    ///   - session: URL session for the request.
    ///   - allowsLogin: If authentication is required and allowsLogin is true, the user will be prompted to authenticate via the Salesforce-hosted web login form.
    /// - Returns: Pubisher
    /// # Reference
    /// [Introduction to Apex REST](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest_intro.htm)
    func apex<T>(
        method: String? = nil,
        namespace: String? = nil,
        relativePath: String,
        queryItems: [URLQueryItem]? = nil,
        headers: [String:String]? = nil,
        body: Data? = nil,
        validator: Validator = .default,
        decoder: JSONDecoder = .salesforce,
        session: URLSession = .shared,
        allowsLogin: Bool = true
    ) -> AnyPublisher<T, Error> where T: Decodable {
    
        let service = ApexService(method: method, namespace: namespace, relativePath: relativePath, queryItems: queryItems, headers: headers, body: body)
        return go(service: service, session: session, allowsLogin: allowsLogin, validator: validator, decoder: decoder)
    }
}
