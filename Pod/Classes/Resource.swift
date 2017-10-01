//
//  Resource.swift
//  SwiftlySalesforce
//
//	For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2017. All rights reserved.
//

public enum Resource {
	
	case identity(version: String)
	case limits(version: String)
	case query(soql: String, version: String)
	case queryNext(path: String)
	case retrieve(type: String, id: String, fields: [String]?, version: String)
	case insert(type: String, fields: [String: Any], version: String)
	case update(type: String, id: String, fields: [String: Any], version: String)
	case delete(type: String, id: String, version: String)
	case describe(type: String, version: String)
	case describeGlobal(version: String)
	case registerForNotifications(deviceToken: String, version: String)
	case apex(method: HTTPMethod, path: String, parameters: [String: Any]?, headers: [String: String]?)
	case custom(method: HTTPMethod, baseURL: URL?, path: String?, parameters: [String: Any]?, headers: [String: String]?)
	
	case revoke(token: String, host: String)
	case refresh(refreshToken: String, consumerKey: String, host: String)
}

public enum HTTPMethod: String {
	case options = "OPTIONS"
	case get     = "GET"
	case head    = "HEAD"
	case post    = "POST"
	case put     = "PUT"
	case patch   = "PATCH"
	case delete  = "DELETE"
	case trace   = "TRACE"
	case connect = "CONNECT"
}

extension Resource {
	
	private var parts: (method: HTTPMethod, path: String?, parameters: [String: Any]?, headers: [String: String]?) {
		
		switch self {
			
		case let .identity(version):
			return (method: .get, path: nil, parameters: ["version": version], headers: nil)
			
		case let .limits(version):
			return (method: .get, path: "/services/data/v\(version)/limits", parameters: nil, headers: nil)
			
		case let .query(soql, version):
			return (method: .get, path: "/services/data/v\(version)/query", parameters: ["q": soql], headers: nil)
			
		case let .queryNext(path):
			return (method: .get, path: path, parameters: nil, headers: nil)
			
		case let .retrieve(type, id, fields, version):
			let params: [String: Any]? = {
				if let fieldNames = fields?.joined(separator: ",") { return ["fields": fieldNames] }
				else { return nil }
			}()
			return (method: .get, path: "/services/data/v\(version)/sobjects/\(type)/\(id)", parameters: params, headers: nil)
			
		case let .insert(type, fields, version):
			return (method: .post, path: "/services/data/v\(version)/sobjects/\(type)/", parameters: fields, headers: ["Content-Type" : "application/json"])
			
		case let .update(type, id, fields, version):
			return (method: .patch, path: "/services/data/v\(version)/sobjects/\(type)/\(id)", parameters: fields, headers: ["Content-Type" : "application/json"])
			
		case let .delete(type, id, version):
			return (method: .delete, path: "/services/data/v\(version)/sobjects/\(type)/\(id)", parameters: nil, headers: nil)
			
		case let .describe(type, version):
			return (method: .get, path: "/services/data/v\(version)/sobjects/\(type)/describe", parameters: nil, headers: nil)
			
		case let .describeGlobal(version):
			return (method: .get, path: "/services/data/v\(version)/sobjects/", parameters: nil, headers: nil)
			
		case let .registerForNotifications(deviceToken, version):
			return (method: .post, path: "/services/data/v\(version)/sobjects/MobilePushServiceDevice", parameters: ["ConnectionToken" : deviceToken, "ServiceType" : "Apple" ], headers: ["Content-Type" : "application/json"])
		
		case let .apex(method, path, parameters, headers):
			return (method: method, path: "/services/apexrest\(path)", parameters: parameters, headers: headers)
			
		case let .custom(method, _, path, parameters, headers):
			return (method: method, path: path, parameters: parameters, headers: headers)
			
		case let .revoke(token, _):
			return (method: .get, path: "/services/oauth2/revoke", parameters: ["token": token], headers: nil)
			
		case let .refresh(refreshToken, consumerKey, _):
			let parameters = [
				"format" : "urlencoded",
				"grant_type": "refresh_token",
				"client_id": consumerKey,
				"refresh_token": refreshToken]
			return (method: .get, path: "/services/oauth2/token", parameters: parameters, headers: nil)
		}
	}

	internal func asURLRequest(authData: OAuth2Result) throws -> URLRequest {
		
		let parts = self.parts
		
		// URL
		var url: URL
		switch self {
		case .identity:
			url = authData.identityURL
		case let .custom(_, baseURL, _, _, _):
			url = (baseURL ?? authData.instanceURL)
		case .revoke(_, let host), .refresh(_, _, let host):
			url = URL(string: "https://\(host)")!
		default:
			url = authData.instanceURL
		}
		if let path = parts.path {
			url = url.appendingPathComponent(path)
		}
		
		// URL request
		var request = URLRequest(url: url)
		request.httpMethod = parts.method.rawValue
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("Bearer \(authData.accessToken)", forHTTPHeaderField: "Authorization")
		if let headers = parts.headers {
			for (key, value) in headers {
				request.addValue(value, forHTTPHeaderField: key)
			}
		}
		
		// Encode parameters
		if let parameters = parts.parameters {
			
			switch parts.method {
				
			case .get, .head, .delete:
				// Encode as query string in URL
				var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
				comps?.queryItems = parameters.map {
					return URLQueryItem(name: $0.key, value: String(describing: $0.value))
				}
				request.url = comps?.url
				request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
				
			default:
				// Encode as JSON in request body
				request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
				request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			}
		}
		
		return request
	}
}
