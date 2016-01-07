# Swiftly Salesforce
_Swiftly Salesforce_ is an easy-to-use framework for building native iOS apps with Swift and the Salesforce Platform.

## Quick Overview
- Written in Swift 2
- Simplifies the [OAuth2] authorization process (aka the OAuth2 "dance")
- Works with [Alamofire] for easy and secure interaction with the Salesforce [REST API]
- Installs with [CocoaPods]: add `pod 'SwiftlySalesforce'` to your [Podfile]
- Check out the code in the included [example] app
- If you have a question, suggestion, or find a bug, [contact me](#contact)

## Background

The goal of _Swiftly Salesforce_ is to lower the barrier to developing custom iOS apps that integrate with the Salesforce Platform. The main value of the current version is simplifying the OAuth2 process, and the interaction with the back-end Salesforce [REST API].

Though I plan to improve and evolve _Swiftly Salesforce_, I want to keep it as simple and lean as possible, and I want to enable you to work with other modern, [complementary frameworks](#complementary-frameworks) that are also narrowly-focused, and which are better at their core functionality than _Swiftly Salesforce_ would be. That said, if it makes sense to expand the capability of _Swiftly Salesforce_, [let me know](#contact) and I'll gladly consider it.

_Swiftly Salesforce_ is a very 'lightweight' alternative to the [Salesforce Mobile SDK][Mobile SDK for iOS], which is much more comprehensive, but it comes with greater complexity, a steeper learning curve, and a larger code base to support backward compatibility and hybrid app development. For me, at least, that can sometimes slow the development of apps that don't require such a comprehensive SDK. 

In addition, I wanted to work with Swift 2, and liked the syntax and ease-of-use of [Alamofire], one of the most popular iOS frameworks. I tried to avoid depending too much on any other framework, but Alamofire is widely-adopted, and well-maintained, and fits very nicely with _Swiftly Salesforce's_ core functionality.

## Getting Started
If you haven't already:

1. [Get](https://developer.salesforce.com/signup) a free Salesforce Developer Edition environment ('org')
2. Create a [Connected App] that will be the server to your iOS mobile app

The easiest way to incorporate _Swiftly Salesforce_ into your Xcode project is with [CocoaPods]; add the  line below to your [Podfile]. 
```
pod 'SwiftlySalesforce' 
```

## Using Swiftly Salesforce

### Configure
```swift
/// Salesforce Connected App settings
let consumerKey = "3MVG91ftikjGaMd_SSivaqQgkik_rz_GVRYmFpDR6yDaUrEfpC0vKqisPMY1klyH78G9Ockl2p7IJuqRk07nQ"
let callbackURL = NSURL(string: "taskforce://authorized")! //TODO: register this URL scheme...
AuthenticationManager.sharedInstance.configureWithConsumerKey(consumerKey, callbackURL: callbackURL)
```

### Query Salesforce
```swift
guard let credentials = AuthenticationManager.sharedInstance.credentials else {
AuthenticationManager.sharedInstance.authenticate()
return
} 
let soql = "SELECT Id,Subject,Status FROM Task ORDER BY CreatedDate DESC LIMIT 100"
Alamofire.request(SalesforceAPI.Query(soql: soql).endpoint(credentials: credentials))
.validate()
.salesforceResponse {
(response) -> Void in
switch response.result {
case .Failure(let error):
if error.isAuthenticationRequiredError() {
// Access token probably expired
AuthenticationManager.sharedInstance.authenticate()
}
else {
// Alert the user
}
case .Success(let value):
if let dict = value as? [String: AnyObject], let records = dict["records"] as? [[String: AnyObject]] {
let tasks = [Task]()
for record in records {
tasks.append(Task(dictionary: record))
}
self.tasks = tasks // Update the model
}
}
}
```

### Update a Salesforce Record
```swift
guard let credentials = AuthenticationManager.sharedInstance.credentials else {
AuthenticationManager.sharedInstance.authenticate()
return
}
let recordUpdate: [String: AnyObject] = ["Status" : selectedStatus ] // Update the status field
Alamofire.request(SalesforceAPI.UpdateRecord(type: "Task", id: task.id, fields: recordUpdate).endpoint(credentials: credentials))
.validate()
.salesforceResponse {
[unowned self]
(response) -> Void in
switch response.result {
case .Success:
task.status = selectedStatus // Update the model
case .Failure(let error):
if error.isAuthenticationRequiredError() {
// Access token probably expired
AuthenticationManager.sharedInstance.authenticate()
}
else {
// Alert the user
}
}
}
```

## Main Components
* [SalesforceAPI]: Acts as a '[router](https://littlebitesofcocoa.com/93-creating-a-router-for-alamofire)' for [Alamofire] requests. The more important, or commonly-used Salesforce [REST API] endpoints are represented as enum values, and I'll add more endpoints over time. You can also easily create [Alamofire] requests for your [custom Apex REST][Apex REST] endpoints, for example, by following the pattern established in this file.

* [Credentials]: Swift struct that holds tokens, and other data, required for each request made to the Salesforce REST API. These values are stored securely in the iOS keychain.

* [Extensions]: Swift extensions used by other components of _Swiftly Salesforce_. The extensions that you'll likely use in your own code are `NSDateFormatter.SalesforceDateTime`, and `NSDateFormatter.SalesforceDate`, for converting Salesforce date/time and date fields to and from strings for JSON serialization, and `Alamofire.Request.salesforceResponse( )` to handle the Salesforce REST API's JSON response.

* [AuthenticationManager]: Singleton that coordinates the OAuth2 authorization process, and securely stores and retrieves the resulting access token. The access token must be included in the header of every HTTP request to the Salesforce REST API. If the access token has expired, the AuthenticationManager will attempt to [refresh][OAuth2 refresh token flow] it. If the refresh process fails, then the AuthenticationManager will call on its delegate to authenticate the user, that is, to display a Salesforce-hosted form into which the user would enter his/her username and password. See [MasterViewController.swift] for an example of the authentication process; it uses a [Safari View Controller](https://developer.apple.com/videos/play/wwdc2015-504/) (new in iOS 9) to authenticate the user via the OAuth2 '[user-agent][OAuth2 user-agent flow]' flow. Though 'user-agent' flow is more complex than the OAuth2 '[username-password][OAuth2 username-password flow]' flow, it is the preferred method of authenticating users to Salesforce, since their passwords are never handled by the client application.

## Complementary Frameworks
Some great Swift frameworks that are complementary to _Swiftly Salesforce_, and which may be useful for your applications:
* [Alamofire]: "Elegant HTTP Networking in Swift"
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON): "The better way to deal with JSON data in Swift"
* [Realm](http://realm.io): "A replacement for SQLite & Core Data"
* [PromiseKit](http://promisekit.org): "...Not just a promises implementation, it is also a collection of helper functions that make the typical asynchronous patterns we use as iOS developers delightful too."

## Resources
If you're new to Swift, the Salesforce Platform, or the Salesforce REST API, you might find the following resources useful.
* [Salesforce REST API Developer's Guide][REST API]
* [Salesforce App Cloud](http://www.salesforce.com/platform): aka the Salesforce Platform
* [Salesforce Developers](https://developer.salesforce.com): official Salesforce developers' site; training, documentation, SDKs, etc.
* [Salesforce Partner Community](https://partners.salesforce.com): "Innovate, grow, connect" with Salesforce ISVs. Join the [Salesforce + iOS Mobile][sfdc-ios Chatter] Chatter group
* [Salesforce Mobile SDK for iOS][Mobile SDK for iOS]: 'official' SDK for developing mobile apps. Written in Objective-C. Available for [Android](https://github.com/forcedotcom/SalesforceMobileSDK-Android), too
* [A Salesforce Swift App](http://www.mobileandemerging.technology/a-salesforce-mobile-app-with-swift/): blog post on using Swift with the Salesforce Mobile SDK. By [Jonathan Jenkins](http://www.mobileandemerging.technology/author/jonathan-jenkins/)
* [When to Use the Salesforce1 Platform vs. Creating Custom Apps](https://help.salesforce.com/HTViewSolution?id=000192840&language=en_US)
* [Alamofire]: Swift version of AFNetworking, "...One of the most popular third-party libraries on iOS and OS X." Tutorial [here](http://www.raywenderlich.com/85080/beginning-alamofire-tutorial).
* [Functional Swift](https://www.objc.io/books/functional-swift/): great book for learning Swift 2, by the team at [objc.io](http://objc.io). See their [other books](https://www.objc.io/books/) on Advanced Swift, and Core Data.
* [iOS Apps with REST APIs](https://grokswift.com/bookshort/?utm_expid=86885646-0.pSwvTyVzSoG5VWML8NMtRw.1&utm_referrer=https%3A%2F%2Fgrokswift.com%2F): great book for getting started with Swift, REST APIs, JSON, and Alamofire. "Only the nitty gritty that you need to get real work done now: interfacing with your web services and displaying the results in your UI." By Christina Moulton of [GrokSwift](https://twitter.com/GrokSwift) 

## About
I'm a senior technical '[evangelist](https://en.wikipedia.org/wiki/Technology_evangelist)' at Salesforce, and I work with [ISV](https://en.wikipedia.org/wiki/Independent_software_vendor) partners who are developing applications on the Salesforce Platform. It's been my favorite platform for about 9 years, well before I became a Salesforce employee, and I've worked with iOS for about 3 years. 

## Contact
If you have a question, suggestion, or find a bug, please contact me:
* Open a [GitHub issue](https://github.com/mike4aday/SwiftlySalesforce/issues)
* Twitter [@mike4aday]
* Join the Salesforce [Partner Community] and post to the '[Salesforce + iOS Mobile][sfdc-ios Chatter]' Chatter group

[Alamofire]: <https://github.com/alamofire/alamofire>
[OAuth2]: <https://developer.salesforce.com/page/Digging_Deeper_into_OAuth_2.0_on_Force.com>
[REST API]: <https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/>
[Swift 2]: <https://developer.apple.com/swift/>
[Podfile]: <https://guides.cocoapods.org/syntax/podfile.html>
[CocoaPods]: <https://cocoapods.org/>
[sfdc-ios Chatter]: <http://sfdc.co/sfdc-ios>
[@mike4aday]: <https://twitter.com/mike4aday>
[Connected App]: <https://help.salesforce.com/apex/HTViewHelpDoc?id=connected_app_overview.htm>
[Partner Community]: <https://p.force.com>
[Apex REST]: <https://developer.salesforce.com/page/Creating_REST_APIs_using_Apex_REST>
[OAuth2 user-agent flow]: <https://help.salesforce.com/apex/HTViewHelpDoc?id=remoteaccess_oauth_user_agent_flow.htm&language=en>
[OAuth2 username-password flow]: <https://help.salesforce.com/apex/HTViewHelpDoc?id=remoteaccess_oauth_username_password_flow.htm&language=en>
[OAuth2 refresh token flow]: <https://help.salesforce.com/apex/HTViewHelpDoc?id=remoteaccess_oauth_refresh_token_flow.htm&language=en_US>
[Example]: <https://github.com/mike4aday/SwiftlySalesforce/tree/master/Example/SwiftlySalesforce>
[Mobile SDK for iOS]: <https://github.com/forcedotcom/SalesforceMobileSDK-iOS>

[SalesforceAPI]: <https://github.com/mike4aday/SwiftlySalesforce/blob/master/Pod/Classes/SalesforceAPI.swift>
[Credentials]: <https://github.com/mike4aday/SwiftlySalesforce/blob/master/Pod/Classes/Credentials.swift>
[Extensions]: <https://github.com/mike4aday/SwiftlySalesforce/blob/master/Pod/Classes/Extensions.swift>
[AuthenticationManager]: <https://github.com/mike4aday/SwiftlySalesforce/blob/master/Pod/Classes/AuthenticationManager.swift>
[MasterViewController.swift]: <https://github.com/mike4aday/SwiftlySalesforce/blob/master/Example/SwiftlySalesforce/MasterViewController.swift>
