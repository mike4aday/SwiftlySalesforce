
<img src="http://mike4aday.github.io/SwiftlySalesforce/images/SwiftlySalesforceLogo.png" width="76%"/>

![Swift](https://img.shields.io/badge/%20in-swift%204-orange.svg)
[![Version](https://img.shields.io/cocoapods/v/SwiftlySalesforce.svg?style=flat)](http://cocoadocs.org/docsets/SwiftlySalesforce)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/SwiftlySalesforce.svg?style=flat)](http://cocoadocs.org/docsets/SwiftlySalesforce)
[![Platform](https://img.shields.io/cocoapods/p/SwiftlySalesforce.svg?style=flat)](http://cocoadocs.org/docsets/SwiftlySalesforce)

Build iOS apps fast on the [Salesforce Platform](http://www.salesforce.com/platform/overview/) with Swiftly Salesforce:
* Written entirely in [Swift](https://developer.apple.com/swift/).
* Uses [promises](https://en.wikipedia.org/wiki/Futures_and_promises) to simplify complex, asynchronous [Salesforce API](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/) interactions.
* Manages the Salesforce [OAuth2] process (the "OAuth dance") automatically and transparently.
* Simpler and lighter alternative to the Salesforce [Mobile SDK for iOS].
* Easy to install and update.

## Quick Start
You can be up and running in a few minutes by following these steps:

1. [Get a free Salesforce Developer Edition](https://developer.salesforce.com/signup) 
1. Create a Salesforce [Connected App] in your new Developer Edition
1. Add Swiftly Salesforce to your Xcode project
    - [CocoaPods](http://www.cocoapods.org): add `pod 'SwiftlySalesforce'` to your [Podfile](https://guides.cocoapods.org/syntax/podfile.html)
    - [Carthage](https://github.com/Carthage/Carthage): add `github "mike4aday/SwiftlySalesforce"` to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile)
1. Configure your app delegate ([example](#example-configure-your-app-delegate))
1. Register your Connected App's callback URL scheme with iOS ([example](#example-register-your-connected-apps-callback-url-scheme-with-ios))

## Minimum Requirements
* iOS 10
* Swift 4
* Xcode 9

## [Documentation](http://mike4aday.github.io/SwiftlySalesforce/docs)
Documentation is [here](http://mike4aday.github.io/SwiftlySalesforce/docs). See especially the public methods of the `Salesforce` class - those are likely all you'll need to call from your code.

## Examples
Below are some examples to illustrate how to use Swiftly Salesforce, and how you can chain complex asynchronous calls. You can also find a complete example app [here](Example/SwiftlySalesforce); it retrieves the logged-in user’s task records from Salesforce, and lets the user update the status of a task.

Swiftly Salesforce will automatically manage the entire Salesforce [OAuth2][OAuth2] process (the "OAuth dance"). If Swiftly Salesforce has a valid access token, it will include that token in the header of every API request. If the token has expired, and Salesforce rejects the request, then Swiftly Salesforce will attempt to refresh the access token, without bothering the user to re-enter the username and password. If Swiftly Salesforce doesn't have a valid access token, or is unable to refresh it, then Swiftly Salesforce will direct the user to the Salesforce-hosted login form.

Behind the scenes, Swiftly Salesforce leverages [PromiseKit][PromiseKit], a very widely-adopted framework for elegant handling of asynchronous operations.

### Example: Configure Your App Delegate
```swift
import UIKit
import SwiftlySalesforce

// Global variable
var salesforce: Salesforce!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LoginDelegate /* 1 */ {

    var window: UIWindow?

    /// Salesforce Connected App properties (replace with your own…) /* 2 */
    let consumerKey = "<YOUR CONNECTED APP’S CONSUMER KEY HERE>" 
    let callbackURL = URL(string: "<YOUR CONNECTED APP’S CALLBACK URL HERE>")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        salesforce = configureSalesforce(consumerKey: consumerKey, callbackURL: callbackURL) /* 3 */
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		handleCallbackURL(url, for: salesforce.connectedApp) /* 4 */
		return true
    }
}
```
Note the following in the above example:

1. Your app delegate should implement `LoginDelegate`.
1. Replace the values for `consumerKey` and `redirectURL` with the values defined in your [Connected App]. Note that your redirect URL should use a custom scheme, not http or https, e.g. `myapp://go`.
1. Create a `Salesforce` instance with your Connected App's values. In the above example, `salesforce` is an implicitly-unwrapped, optional, global variable; you could also inject a `Salesforce` instance into your root view controller, for example, instead of using a global variable.
1. Add a call to `handleCallbackURL()` as shown. iOS will invoke it at the conclusion of the OAuth2 user-agent flow, when Salesforce redirects the user back to your app.

### Example: Retrieve Salesforce Records
The following will retrieve all the fields for an account record:
```swift
salesforce.retrieve(type: "Account", id: "0013000001FjCcF")
```
To specify which fields should be retrieved:
```swift
let fields = ["AccountNumber", "BillingCity", "MyCustomField__c"]
salesforce.retrieve(type: "Account", id: "0013000001FjCcF", fields: fields)
```
Note that `retrieve` is an asynchronous function, whose return value is a "promise" that will be fulfilled at some point in the future:
```swift
let promise: Promise<Record> = salesforce.retrieve(type: "Account", id: "0013000001FjCcF")
```
And you can add a closure that will be called later, when the promise is fulfilled:
```swift
salesforce.retrieve(type: "Account", id: "0013000001FjCcF").then {
    (queryResult: QueryResult<Record>) -> () in
    for record: Record in queryResult.records {
        // Do something more interesting with each record
        debugPrint(record.type)
    }
}.catch {
    (error: Error) in
    // Do something with the error
}
```
You can retrieve multiple records in parallel, and wait for them all before proceeding:
```swift
first {
    // (Enclosing this in a ‘first’ block is optional; it keeps things neat.)
    let ids = ["001i0000020i19F", "001i0000034i18A", "001i0000020i22B"]
    return salesforce.retrieve(type: "Account", ids: ids)
}.then {
    (records: [Record]) -> () in
    for record in records {
        if let name = record.string(forField: "Name"), let modifiedDate = record.date(forField: "LastModifiedDate") {
            debugPrint(name)
            debugPrint(modifiedDate)
        }
    }
}.catch {
    error in
    // Handle error...
}
```

### Example: Custom Model Objects (NEW!)
Instead of using `Record`, you could define your own model objects. Swiftly Salesforce will automatically decode the Salesforce response into your model objects, as long as they implement Swift's [`Decodable`](https://developer.apple.com/documentation/swift/decodable) protocol:
```swift
struct MyAccountModel: Decodable {

    var id: String
    var name: String
    var createdDate: Date
    var billingAddress: Address?
    var website: URL?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case createdDate = "CreatedDate"
        case billingAddress = "BillingAddress"
        case website = "Website"
    }
}

//...
first {
    // (Enclosing this in a ‘first’ block is optional; it keeps things neat.)
    let ids = ["001i0000020i19F", "001i0000034i18A", "001i0000020i22B"]
    return salesforce.retrieve(type: "Account", ids: ids)
}.then {
    (records: [MyAccountModel]) -> () in
    for record in records {
        // Do something more interesting with record data
        let id = record.id
        let name = record.name
        let createdDate = record.createdDate
        let billingAddress = record.billingAddress
        let website = record.website
    }
}.catch {
    error in
    // Handle error...
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

You could also use the `Record` type to update a record in Salesforce, for example:

```
// `account` is a Record we retrieved earlier...
account.setValue("My New Corp.", forField: "Name")
account.setValue(URL(string: "https://www.mynewcorp.com")!, forField: "Website")
account.setValue("123 Main St.", forField: "BillingStreet")
account.setValue(nil, forField: "Sic")
salesforce.update(record: account).then {
    print("Account updated...")
}.catch {
    error in
    // Handle error
}
```

### Example: Query Salesforce
```swift
let soql = "SELECT Id,Name FROM Account WHERE BillingPostalCode = '10024'"
salesforce.query(soql: soql).then {
    (queryResult: QueryResult) -> () in
    for record in queryResult.records {
        // Do something more interesting with each record
        if let name = record.string(forField: "Name") {
            print("Account name: \(name)")
        }
    }
}.catch {
    error in
    // Handle the error
}
```

You could also execute multiple queries at once and wait for them all to complete before proceeding:
```swift
first {
    let queries = ["SELECT Name FROM Account", "SELECT Id FROM Contact", "Select Owner.Name FROM Lead"]
    return salesforce.query(soql: queries)
}.then {
    (queryResults: [QueryResult<Record>]) -> () in
    // Results are in the same order as the queries
}.catch {
    error in
    // Handle the error
}
```

### Example: Decode Query Results as Custom Model Objects (NEW!)
You can easily perform complex queries, traversing object relationships, and have all the results decoded automatically into your custom model objects that implement the [`Decodable`](https://developer.apple.com/documentation/swift/decodable) protocol:
```swift 
struct Account: Decodable {

    var id: String
    var name: String
    var lastModifiedDate: Date

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case lastModifiedDate = "LastModifiedDate"
    }
}

struct Contact: Decodable {

    var id: String
    var firstName: String
    var lastName: String
    var createdDate: Date
    var account: Account?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case firstName = "FirstName"
        case lastName = "LastName"
        case createdDate = "CreatedDate"
        case account = "Account"
    }
}

func getContactsWithAccounts() -> () {
    let soql = "SELECT Id, FirstName, LastName, CreatedDate, Account.Id, Account.Name, Account.LastModifiedDate FROM Contact"
    salesforce.query(soql: soql).then {
        (queryResult: QueryResult<Contact>) -> () in
        for contact in queryResult.records {
            // Do something more interesting with each Contact record
            debugPrint(contact.lastName)
            if let account = contact.account {
                // Do something more interesting with each Account record
                debugPrint(account.name)
            }
        }
    }.catch {
        error in
        // Handle error
    }
}
```

### Example: Chaining Asynchronous Requests
Let's say we want to retrieve a random zip/postal code from a [custom Apex REST](https://developer.salesforce.com/page/Creating_REST_APIs_using_Apex_REST) resource, and then use that zip code in a query:
```swift
// Chained asynch requests
first {
    // Make GET request of custom Apex REST resource that returns a zip code as a string
    return salesforce.apex(path: "/MyApexResourceThatEmitsRandomZip")
}.then {
    // Query accounts in that zip code
    (result: Data) -> Promise<QueryResult<Record>> in
    guard let zip = String(data: result, encoding: .utf8) else {
        throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
    }
    let soql = "SELECT Id,Name FROM Account WHERE BillingPostalCode = '\(zip)'"
    return salesforce.query(soql: soql)
}.then {
    queryResult -> () in
    for record in queryResult.records {
        if let name = record.string(forField: "Name") {
            print("Account name = \(name)")
        }
    }
}.catch {
    error in
    // Handle error
}
```
You could repeat this chaining multiple times, feeding the result of one asynchronous operation as the input to the next. Or you could spawn multiple, simultaneous operations and easily specify logic to be executed when all operations complete, or when just the first completes, or when any one operation fails, etc. PromiseKit is an amazingly-powerful framework for handling multiple asynchronous operations that would otherwise be very difficult to coordinate. See [PromiseKit documentation](http://promisekit.org) for more examples.

### Example: Retrieve a User's Photo
```swift
// "first" block is an optional way to make chained calls easier to read...
first {
    salesforce.identity()
}.then {
    (identity) -> Promise<UIImage> in
    if let photoURL = identity.photoURL {
        return salesforce.fetchImage(url: photoURL)
    }
    else {
        // Return the default image instead
        return Promise(value: defaultImage)
    }
}.then {
    image in
    self.photoView.image = image
}.always {
    self.refreshControl?.endRefreshing()
}.catch {
    (error) -> () in
    // Handle any errors
}
```

### Example: Retrieve a Contact's Photo
```swift	
first {
    salesforce.retrieve(type: "Contact", id: "003f40000027GugAAE")
}.then {
    (record: Record) -> Promise<UIImage> in
    if let photoPath = record.string(forField: "PhotoUrl") {
        // Fetch image
        return salesforce.fetchImage(path: photoPath)
    }
    else {
        // Return a pre-defined default image
        return Promise(value: self.defaultImage)
    }
}.then {
    (image: UIImage) -> () in
    // Do something interesting with the image, e.g. display in a view:
    // self.photoView.image = image
}.always {
    self.refreshControl?.endRefreshing()
}.catch {
    (error) -> () in
    // Handle any errors
}
```

### Example: Retrieve an Account's Billing Address
Addresses for standard objects, e.g. Account and Contact, are stored in a ['compound' Address field](https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/compound_fields_address.htm), and, if you enable the [geocode data integration rules](https://help.salesforce.com/articleView?id=data_dot_com_clean_admin_clean_rules.htm&language=en_US&type=0) in your org, Salesforce will automatically geocode those addresses, giving you latitude and longitude values you could use for map markers. 
```swift
first {
    salesforce.retrieve(type: "Account", id: "001f40000036J5mAAE")
}.then {
    (record: Record) -> () in
    if let address = record.address(forField: "BillingAddress"), let lon = address.longitude, let lat = address.latitude {
	// You could put a marker on a map...
        print("LAT/LON: \(lat)/\(lon)")
    }
}.catch {
    (error) -> () in
    // Handle any errors
}
```

Or use your own custom `Decodable` model class, instead of the default `Record`:
```swift
struct MyAccountModel: Decodable {
			
    var id: String
    var name: String
    var billingAddress: Address?
			
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case billingAddress = "BillingAddress"
    }
}
// ...
first {
    salesforce.retrieve(type: "Account", id: "001f40000036J5mAAE")
}.then {
    (record: MyAccountModel) -> () in
    if let address = record.billingAddress, let lon = address.longitude, let lat = address.latitude {
        // You could put a marker on a map...
        print("LAT/LON: \(lat)/\(lon)")
    }
}.catch {
    (error) -> () in
    // Handle any errors
}
```

### Example: Handling Errors
The following code is adapted from the example file, [TaskStore.swift](Example/SwiftlySalesforce/TaskStore.swift) and shows how to handle errors:
```swift
first {
    // Get ID of current user
    //TODO: if user already authorized, then we could just get user ID from salesforce.authData
    salesforce.identity()
}.then {
    // Get tasks owned by user (we assume all records are returned in a single 'page'...)
    userInfo -> Promise<QueryResult<Task>> in
    let soql = "SELECT Id,CreatedDate,Subject,Status,IsHighPriority,What.Name FROM Task WHERE OwnerId = '\(userInfo.userID)' ORDER BY CreatedDate DESC"
    return salesforce.query(soql: soql)
}.then {
    // Parse JSON into Task instances
    (result: QueryResult<Task>) -> () in
    let tasks: [Task] = result.records
    // Do something with tasks, e.g. display in table view
}.catch {
    error in
    // Handle error
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

### Example: Retrieve Object Metadata
If, for example, you want to determine whether the user has permission to update or delete a record so you can disable editing in your UI, or if you want to retrieve all the options in a picklist, rather than hardcoding them in your mobile app, then call `salesforce.describe(type:)` to retrieve an object's [metadata](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_describe.htm):
```swift
first {
    salesforce.describe(type: "Account")
}.then {
    (accountMetadata) -> () in
    self.saveButton.isEnabled = accountMetadata.isUpdateable
    if let fields = accountMetadata.fields {
        let fieldDict = Dictionary(items: fields, key: { $0.name })
        let industryOptions = fieldDict["Industry"]?.picklistValues
        // Populate a drop-down menu with the picklist values...
    }
}.catch {
    error in
    debugPrint(error)
}
```

You can retrieve metadata for multiple objects in parallel, and wait for all before proceeding:
```swift
first {
    salesforce.describe(types: ["Account", "Contact", "Task", "CustomObject__c"])
}.then {
    results -> () in
    // results is an array of ObjectMetadatas, in the same order as requested
}.catch {
    error in
    // Handle the error
}
```

### Example: Log Out
If you want to log out the current Salesforce user, and then clear any locally-cached data, you could call the following. Swiftly Salesforce will revoke and remove any stored credentials, and automatically display a Safari View Controller with the Salesforce login page, ready for another user to log in.
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

### Example: Add Swiftly Salesforce to Your CocoaPods [Podfile](https://guides.cocoapods.org/syntax/podfile.html)
```
target 'MyApp' do
  use_frameworks!
  pod 'SwiftlySalesforce'
  # Another pod here
end
```

### Example: Register Your Connected App's Callback URL Scheme with iOS
Upon successful OAuth2 authorization, Salesforce will redirect the Safari View Controller back to the callback URL that you specified in your Connected App settings, and will append the access token (among other things) to that callback URL. Add the following to your app's .plist file, so iOS will know how to handle the callback URL, and will pass it to your app's delegate.
```xml
<!-- ADD TO YOUR APP'S .PLIST FILE -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>SalesforceOAuth2</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string><!-- YOUR CALLBACK URL'S SCHEME HERE (scheme only, not entire URL! Must be custom scheme, not https) --></string>
    </array>
  </dict>
</array>
```

## Main Components of Swiftly Salesforce
* [Salesforce.swift]: This is your Swift interface to the Salesforce Platform, and likely the only file you’ll refer to. It has methods to query, retrieve, update and delete records, and to access [custom Apex REST][Apex REST] endpoints.

* [Resource.swift]: Acts as a '[router](https://littlebitesofcocoa.com/93-creating-a-router-for-alamofire)' for Salesforce API requests. The more important and commonly-used Salesforce [REST API] endpoints are represented as enum values, including one for [custom Apex REST][Apex REST] endpoints.

* [OAuth2Result.swift]: Swift struct that holds tokens, and other data, required for each request made to the Salesforce REST API. These values are stored securely in the iOS keychain.

* [Extensions.swift]: Swift extensions used by other components of Swiftly Salesforce. 

* [ConnectedApp.swift]: Coordinates the OAuth2 authorization process, and securely stores and retrieves the resulting access token. The access token must be included in the header of every HTTP request to the Salesforce REST API. If the access token has expired, the ConnectedApp instance will attempt to [refresh][OAuth2 refresh token flow] it. If the refresh process fails, then ConnectedApp will call on its delegate to authenticate the user, that is, to display a Salesforce-hosted web login form. The default implementation uses a [Safari View Controller](https://developer.apple.com/videos/play/wwdc2015-504/) (new in iOS 9) to authenticate the user via the OAuth2 '[user-agent][OAuth2 user-agent flow]' flow. Though 'user-agent' flow is more complex than the OAuth2 '[username-password][OAuth2 username-password flow]' flow, it is the preferred method of authenticating users to Salesforce, since their credentials are never handled by the client application.

## Dependent Framework
Swiftly Salesforce depends on [PromiseKit](http://promisekit.org): "Not just a promises implementation, it is also a collection of helper functions that make the typical asynchronous patterns we use as iOS developers delightful too."

## Resources
If you're new to the Salesforce Platform or the Salesforce REST API, you might find the following resources useful:
* [Salesforce REST API Developer's Guide][REST API]
* [Salesforce Platform](http://www.salesforce.com/platform)
* [Salesforce Developers](https://developer.salesforce.com): official Salesforce developers' site; training, documentation, SDKs, etc.
* [Salesforce Partner Community](https://partners.salesforce.com): "Innovate, grow, connect" with Salesforce ISVs. Join the [Salesforce + iOS Mobile][sfdc-ios Chatter] Chatter group
* [Salesforce Mobile SDK for iOS][Mobile SDK for iOS]: Salesforce-supported SDK for developing mobile apps. Written in Objective-C. Available for [Android](https://github.com/forcedotcom/SalesforceMobileSDK-Android), too
* [When to Use the Salesforce1 Platform vs. Creating Custom Apps](https://help.salesforce.com/HTViewSolution?id=000192840&language=en_US)

## Contact
Questions, suggestions, bug reports and code contributions welcome:
* Open a [GitHub issue](https://github.com/mike4aday/SwiftlySalesforce/issues)
* Twitter [@mike4aday]
* Join the Salesforce [Partner Community] and post to the '[Salesforce + iOS Mobile][sfdc-ios Chatter]' Chatter group

   [PromiseKit]: <https://github.com/mxcl/PromiseKit>
   [OAuth2]: <https://developer.salesforce.com/page/Digging_Deeper_into_OAuth_2.0_on_Force.com>
   [REST API]: <https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/>
   [Swift]: <https://developer.apple.com/swift/>
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
   [Resource.swift]: <Pod/Classes/Resource.swift>
   [OAuth2Result.swift]: <Pod/Classes/OAuth2Result.swift>
   [Extensions.swift]: <Pod/Classes/Extensions.swift>
   [ConnectedApp.swift]: <Pod/Classes/ConnectedApp.swift>
