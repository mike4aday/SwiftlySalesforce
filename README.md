![Salesforce powered](http://mike4aday.github.io/SwiftlySalesforce/images/SFDCPowered.jpg)

# Swiftly Salesforce
_Swiftly Salesforce_ is a framework for the rapid development of native iOS mobile apps that interact with the [Salesforce Platform](http://www.salesforce.com/platform/overview/).
* Written entirely in [Swift](https://developer.apple.com/swift/), Apple's "modern programming language that is safe, fast and interactive."
* Enables elegant, painless coding for complex, asynchronous [Salesforce API][REST API] interactions
* Manages the Salesforce [OAuth2] authorization process (the "OAuth dance") automatically and transparently
* Simpler and lighter alternative to the Salesforce [Mobile SDK for iOS]
* Easy to install and update

## How do I set up Swiftly Salesforce?
You can be up and running in a few minutes by following these steps:

1. [Get](https://developer.salesforce.com/signup) a free Salesforce Developer Edition
1. Set up a Salesforce [Connected App]
1. Register your Connected App's callback URL scheme with iOS ([see appendix](#appendix))
1. Add _Swiftly Salesforce_ to your Xcode project: 
 * Add `pod 'SwiftlySalesforce'` to your project's [Podfile](https://guides.cocoapods.org/syntax/podfile.html)  ([see appendix](#appendix))
 * Or just copy these [Swift source files](./Pod/Classes) into your project, and add the [dependent frameworks](#dependent-frameworks)
1. Configure your app delegate for _Swiftly Salesforce_ ([see appendix](#appendix))
1. Add an ATS exception for salesforce.com ([see appendix](#appendix)) 

Minimum requirements:
* iOS 10.0
* Swift 3
* Xcode 8

## Documentation
Documentation is [here](http://cocoadocs.org/docsets/SwiftlySalesforce). See especially the public methods of the `Salesforce` class - those are likely all you'll need to call from your code.

## Examples
Below are some examples to illustrate how to use _Swiftly Salesforce_, and how you can chain complex asynchronous calls. You can also find a complete example app [here](Example/SwiftlySalesforce); it retrieves the logged-in user’s task records from Salesforce, and enables the user to update the status of a task.

_Swiftly Salesforce_ will automatically manage the entire Salesforce [OAuth2][OAuth2] process (the "OAuth dance"). If _Swiftly Salesforce_ has a valid access token, it will include that token in the header of every API request. If the token has expired, and Salesforce rejects the request, then _Swiftly Salesforce_ will attempt to refresh the access token, without bothering the user to re-enter the username and password. If _Swiftly Salesforce_ doesn't have a valid access token, or is unable to refresh it, then _Swiftly Salesforce_ will direct the user to the Salesforce-hosted login form.

Behind the scenes, _Swiftly Salesforce_ leverages [Alamofire][Alamofire] and [PromiseKit][PromiseKit], two very widely-adopted frameworks, for elegant handling of networking requests and asynchronous operations. 

### Example: Configure Your App to Talk to Salesforce
```swift
import UIKit
import SwiftlySalesforce

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LoginDelegate {

    var window: UIWindow?
	
    /// Salesforce Connected App properties (replace with your own…)
    let consumerKey = "3MVG91ftiraGaMd_SSxxaqQgk21_rz_GVRxxFpDR6yDaxxEfpC0vKresPMY1kopH98G9Ockl2p7IJuqRk23nQ"
    let redirectURL = URL(string: "taskforce://authorized")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureSalesforce(consumerKey: consumerKey, redirectURL: redirectURL)
        return true
    }
	
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        handleRedirectURL(url: url as URL)
        return true
    }
}
```
Note the following in the above example:

1. Your app delegate should implement `LoginDelegate`
1. Replace the values for `consumerKey` and `redirectURL` with the values defined in your [Connected App]
1. Call `configureSalesforce()` and `handleRedirectURL()` as shown

### Example: Retrieve a Salesforce Record
The following will retrieve all the fields for an account record:
```swift
salesforce.retrieve(type: "Account", id: "0013000001FjCcF")
```
To specify which fields should be retrieved:
```swift
let fields = ["AccountNumber", "BillingCity", "MyCustomField__c"]
salesforce.retrieve(type: "Account", id: "0013000001FjCcF", fields: fields)
```
Note that `retrieve()` is an asynchronous function, whose return value is a "promise" that will be fulfilled at some point in the future:
```swift
let promise = salesforce.retrieve(type: "Account", id: "0013000001FjCcF")
```
And we can add a closure that will be called later, when the promise is fulfilled:
```swift
promise.then {
	queryResult in
	for record in queryResult.records {
		// Parse JSON dictionary of record fields & values, and do interesting stuff…
	}
}
```
### Example: Update a Salesforce Record
```swift
salesforce.update(type: "Task", id: "00T1500001h3V5NEAU", fields: ["Status": "Completed"])
.then {
	(_) -> () in
	// Update the local model
}.always {
	// Update the UI
}
```
The `always` closure will be called regardless of success or failure elsewhere in the promise chain.
### Example: Querying
```swift
let soql = "SELECT Id,Name FROM Account WHERE BillingPostalCode = '\(postalCode)'"
salesforce.query(soql: soql)
```
See the next example for handling the query results.

### Example: Chaining Asynchronous Requests
Let's say we want to retrieve a random zip/postal code from a [custom Apex REST](https://developer.salesforce.com/page/Creating_REST_APIs_using_Apex_REST) resource, and then use that zip code in a query:
```swift
// Chained asynch requests 
first {
    // Make GET request of custom Apex REST resource
    // (Enclosing this in a ‘first’ block is optional and can keep things neat.)
    salesforce.apexRest(path: "/MyApexResourceThatEmitsRandomZip")
}.then {
    // Query accounts in that zip code
    result in
    guard let zip = result["zip"] as? String else {
        throw TaskForceError.generic(100, “Can’t get random zip code from our custom REST endpoint!”)
    }
    let soql = "SELECT Id,Name FROM Account WHERE BillingPostalCode = '\(zip)'"
    return salesforce.query(soql: soql)
}.then {
    queryResult in
    for record in queryResult.records {
        if let name = record["Name"] as? String {
          print("Account name = \(name)")
        }
    }
}
```
You could repeat this chaining multiple times, feeding the result of one asynchronous operation as the input to the next. Or you could spawn multiple, simultaneous operations and easily specify logic to be executed when all operations complete, or when just the first completes, or when any one operation fails, etc. PromiseKit is an amazingly-powerful framework for handling multiple asynchronous operations that would otherwise be very difficult to coordinate. See [PromiseKit documentation](http://promisekit.org) for more examples.

### Example: Handling Errors
The following code is adapted from the example file, [TaskStore.swift](Example/SwiftlySalesforce/TaskStore.swift) and shows how to handle errors:
```swift
first {
    // Get ID of current user
    salesforce.identity()
}.then {
    // Query tasks owned by user
    userInfo in
    guard let userID = userInfo.userID else {
        throw TaskForceError.generic(code: 100, message: "Can't determine user ID")
    }
    let soql = "SELECT Id,Subject,Status,What.Name FROM Task WHERE OwnerId = '\(userID)' ORDE 	R BY CreatedDate DESC"
    return salesforce.query(soql: soql)
}.then {
    // Parse JSON into Task instances
    (result: QueryResult) -> () in
    let tasks = result.records.map { Task(dictionary: $0) }
    // Do something interesting with the tasks…
}.catch {
    error in
    // Handle the error…
}
```
You could also recover from an error, and continue with the chain, using a `recover` closure. The following snippet is from PromiseKit's [documentation](http://promisekit.org/recovering-from-errors):
```swift
CLLocationManager.promise().recover { err in
    guard !err.fatal else { throw err }
    return CLLocationChicago
}.then { location in
    // the user’s location, or Chicago if an error occurred
}.catch { err in
    // the error was fatal
}
```
### Example: Log Out
If you want to log out the current Salesforce user, and then clear any locally-cached data, you could call the following. _Swiftly Salesforce_ will revoke and remove any stored credentials, and automatically display a Safari View Controller with the Salesforce login page, ready for another user to log in.
```swift
// Call this when your app's "Log Out" button is tapped, for example
if let app = UIApplication.shared.delegate as? LoginDelegate {
    app.logout().then {
        () -> () in
        // Clear any cached data and reset the UI
        return
    }.catch {
        error in
        debugPrint(error)
    }
}
```

## Main Components of Swiftly Salesforce
* [Salesforce.swift]: This is your Swift interface to the Salesforce Platform, and likely the only file you’ll refer to. It has methods to query, retrieve, update and delete records, and to access [custom Apex REST][Apex REST] endpoints.

* [Router.swift]: Acts as a '[router](https://littlebitesofcocoa.com/93-creating-a-router-for-alamofire)' for [Alamofire] requests. The more important and commonly-used Salesforce [REST API] endpoints are represented as enum values, including one for [custom Apex REST][Apex REST] endpoints.

* [AuthData.swift]: Swift struct that holds tokens, and other data, required for each request made to the Salesforce REST API. These values are stored securely in the iOS keychain.

* [Extensions.swift]: Swift extensions used by other components of _Swiftly Salesforce_. The extensions that you'll likely use in your own code are `DateFormatter.salesforceDateTime`, and `DateFormatter.salesforceDate`, for converting Salesforce date/time and date values to and from strings for JSON serialization.

* [AuthManager.swift]: Coordinates the OAuth2 authorization process, and securely stores and retrieves the resulting access token. The access token must be included in the header of every HTTP request to the Salesforce REST API. If the access token has expired, the AuthManager will attempt to [refresh][OAuth2 refresh token flow] it. If the refresh process fails, then AuthManager will call on its delegate to authenticate the user, that is, to display a Salesforce-hosted web login form. The default implementation uses a [Safari View Controller](https://developer.apple.com/videos/play/wwdc2015-504/) (new in iOS 9) to authenticate the user via the OAuth2 '[user-agent][OAuth2 user-agent flow]' flow. Though 'user-agent' flow is more complex than the OAuth2 '[username-password][OAuth2 username-password flow]' flow, it is the preferred method of authenticating users to Salesforce, since their credentials	 are never handled by the client application.

## Dependent Frameworks
The great Swift frameworks leveraged by _Swiftly Salesforce_:
* [PromiseKit](http://promisekit.org): "Not just a promises implementation, it is also a collection of helper functions that make the typical asynchronous patterns we use as iOS developers delightful too."
* [Alamofire](https://github.com/Alamofire/Alamofire): "Elegant HTTP Networking in Swift"
* [Locksmith](https://github.com/matthewpalmer/Locksmith): "A powerful, protocol-oriented library for working with the keychain in Swift."

## Resources
If you're new to Swift, the Salesforce Platform, or the Salesforce REST API, you might find the following resources useful:
* [Salesforce REST API Developer's Guide][REST API]
* [Salesforce App Cloud](http://www.salesforce.com/platform): aka the Salesforce Platform
* [Salesforce Developers](https://developer.salesforce.com): official Salesforce developers' site; training, documentation, SDKs, etc.
* [Salesforce Partner Community](https://partners.salesforce.com): "Innovate, grow, connect" with Salesforce ISVs. Join the [Salesforce + iOS Mobile][sfdc-ios Chatter] Chatter group
* [Salesforce Mobile SDK for iOS][Mobile SDK for iOS]: Salesforce-supported SDK for developing mobile apps. Written in Objective-C. Available for [Android](https://github.com/forcedotcom/SalesforceMobileSDK-Android), too
* [A Salesforce Swift App](http://www.mobileandemerging.technology/a-salesforce-mobile-app-with-swift/): blog post on using Swift with the Salesforce Mobile SDK. By [Jonathan Jenkins](http://www.mobileandemerging.technology/author/jonathan-jenkins/)
* [When to Use the Salesforce1 Platform vs. Creating Custom Apps](https://help.salesforce.com/HTViewSolution?id=000192840&language=en_US)
* [Alamofire]: Swift version of AFNetworking, "...One of the most popular third-party libraries on iOS and OS X." Tutorial [here](http://www.raywenderlich.com/85080/beginning-alamofire-tutorial).
* [iOS Apps with REST APIs](https://grokswift.com/bookshort/?utm_expid=86885646-0.pSwvTyVzSoG5VWML8NMtRw.1&utm_referrer=https%3A%2F%2Fgrokswift.com%2F): great book for getting started with Swift, REST APIs, JSON, and Alamofire. "Only the nitty gritty that you need to get real work done now: interfacing with your web services and displaying the results in your UI." By Christina Moulton of [GrokSwift](https://twitter.com/GrokSwift) 
* [Salesforce Mobile SDK Quick Start](http://www.centare.com/salesforce-mobile-sdk-quickstart/): blog post by [William Welbes](https://twitter.com/welbes)

## About Me
I'm a senior technical '[evangelist](https://en.wikipedia.org/wiki/Technology_evangelist)' at Salesforce, and I work with [ISV](https://en.wikipedia.org/wiki/Independent_software_vendor) partners who are building applications on the Salesforce Platform. 

## Contact
Questions, suggestions, bug reports and code contributions welcome:
* Open a [GitHub issue](https://github.com/mike4aday/SwiftlySalesforce/issues)
* Twitter [@mike4aday]
* Join the Salesforce [Partner Community] and post to the '[Salesforce + iOS Mobile][sfdc-ios Chatter]' Chatter group

## Appendix

### Add Swiftly Salesforce to Your CocoaPods Podfile
Adding _Swiftly Salesforce_ to a simple Podfile:
```
target 'MyApp' do
  use_frameworks!
  pod 'SwiftlySalesforce'
  # Another pod here
end
```
See [Podfile](https://guides.cocoapods.org/syntax/podfile.html) for more details

### Register Your Connected App's Callback URL Scheme with iOS
Upon successful OAuth2 authorization, Salesforce will redirect the Safari View Controller back to the callback URL that you specified in your Connected App settings, and will append the access token (among other things) to that callback URL. Add the following to your app's .plist file, so iOS will know how to handle the URL, and will pass it to your app's delegate.
```xml
<!-- ADD TO YOUR APP'S .PLIST FILE -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>SalesforceOAuth2CallbackURLScheme</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string><!-- YOUR CALLBACK URL'S SCHEME HERE (scheme only, not entire URL) --></string>
    </array>
  </dict>
</array>
```
Then, you just need to add a single line in your app delegate class so that _Swiftly Salesforce_ will handle the callback URL and the appended credentials.
```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    handleRedirectURL(redirectURL: url as URL)
    return true
}
```

### Configure your App Delegate for Swiftly Salesforce
Update your app delegate class so that it:
* Configures _Swiftly Salesforce_ with your Connected App's consumer key and callback URL
* Implements `LoginDelegate` - you don't have to implement any methods, though, thanks to the magic of Swift's [protocol extensions](http://www.codingexplorer.com/protocol-extensions-in-swift-2/)
* Calls `handleRedirectURL(redirectURL:)` when asked by iOS to open the callback URL.

```swift
import UIKit
import SwiftlySalesforce

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LoginDelegate {

    var window: UIWindow?
	
    /// Salesforce Connected App properties (replace with your own...)
    let consumerKey = "< YOUR CONNECTED APP’S CONSUMER KEY HERE >"
    let redirectURL = URL(string: "< YOUR CONNECTED APP’S REDIRECT URL HERE >")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureSalesforce(consumerKey: consumerKey, redirectURL: redirectURL)
        return true
    }
	
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        handleRedirectURL(redirectURL: url as URL)
        return true
    }
}
```

### Add an ATS Exception for Salefsorce
As of this writing, you need to add an [application transport security (ATS) exception](https://ste.vn/2015/06/10/configuring-app-transport-security-ios-9-osx-10-11/) to your iOS application's .plist file to allow it to connect to salesforce.com, as follows:
```xml
<!-- ADD TO YOUR APP'S .PLIST FILE -->
<key>NSAppTransportSecurity</key>
<dict>
	<key>NSExceptionDomains</key>
	<dict>
		<key>salesforce.com</key>
		<dict>
			<key>NSExceptionRequiresForwardSecrecy</key>
			<false/>
			<key>NSIncludesSubdomains</key>
			<true/>
		</dict>
	</dict>
</dict>
```

   [Alamofire]: <https://github.com/alamofire/alamofire>
   [PromiseKit]: <https://github.com/mxcl/PromiseKit>
   [OAuth2]: <https://developer.salesforce.com/page/Digging_Deeper_into_OAuth_2.0_on_Force.com>
   [REST API]: <https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/>
   [Swift 2]: <https://developer.apple.com/swift/>
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
   
   [Salesforce.swift]: <Pod/Classes/Salesforce.swift>
   [Router.swift]: <Pod/Classes/Router.swift>
   [AuthData.swift]: <Pod/Classes/AuthData.swift>
   [Extensions.swift]: <Pod/Classes/Extensions.swift>
   [AuthManager.swift]: <Pod/Classes/AuthManager.swift>

