
<img src="http://mike4aday.github.io/SwiftlySalesforce/images/SwiftlySalesforceLogo.png" width="76%"/>

<img src="https://img.shields.io/badge/%20in-swift%204-orange.svg"/>&nbsp;<img src="https://img.shields.io/cocoapods/v/SwiftlySalesforce.svg?style=flat"/>&nbsp;<img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"/>&nbsp;<img src="https://img.shields.io/cocoapods/l/SwiftlySalesforce.svg?style=flat"/>&nbsp;<img src="https://img.shields.io/cocoapods/p/SwiftlySalesforce.svg?style=flat"/>

Build iOS apps fast on the [Salesforce Platform](http://www.salesforce.com/platform/overview/) with Swiftly Salesforce:
* Written entirely in [Swift](https://developer.apple.com/swift/).
* Uses [promises](https://en.wikipedia.org/wiki/Futures_and_promises) to simplify complex, asynchronous [Salesforce API](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/) interactions.
* Manages the Salesforce [OAuth2] user authentication and authorization process (the "OAuth dance") automatically.
* Simpler and lighter alternative to the Salesforce [Mobile SDK for iOS].
* Easy to install and update.
* Compatible with [Realm](http://realm.io) for a complete, offline mobile solution.
* [See what's new](./CHANGELOG.md).

## Quick Start
You can be up and running in a few minutes by following these steps:

1. [Get a free Salesforce Developer Edition](https://developer.salesforce.com/signup) 
1. Create a Salesforce [Connected App] in your new Developer Edition
1. Add Swiftly Salesforce to your Xcode project
    - [CocoaPods](http://www.cocoapods.org): add `pod 'SwiftlySalesforce'` to your [Podfile](https://guides.cocoapods.org/syntax/podfile.html)
    - [Carthage](https://github.com/Carthage/Carthage): add `github "mike4aday/SwiftlySalesforce"` to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile)
1. Configure your app delegate ([example](#example-configure-your-app-delegate))

## Minimum Requirements
* iOS 11.3
* Swift 4
* Xcode 9

## [Documentation](http://mike4aday.github.io/SwiftlySalesforce/docs)
Documentation is [here](http://mike4aday.github.io/SwiftlySalesforce/docs). See especially the public methods of the `Salesforce` class - those are likely all you'll need to call from your code.

## Examples
Below are some examples that illustrate how to use Swiftly Salesforce, and how you can chain complex asynchronous calls. You can also find a complete example app [here](Example/SwiftlySalesforce); it retrieves the logged-in user’s task records from Salesforce, and lets the user update the status of a task.

Swiftly Salesforce will automatically manage the entire Salesforce [OAuth2][OAuth2] process (the "OAuth dance"). If Swiftly Salesforce has a valid access token, it will include that token in the header of every API request. If the token has expired, and Salesforce rejects the request, then Swiftly Salesforce will attempt to refresh the access token, without bothering the user to re-enter the username and password. If Swiftly Salesforce doesn't have a valid access token, or is unable to refresh it, then Swiftly Salesforce will direct the user to the Salesforce-hosted login form.

Behind the scenes, Swiftly Salesforce leverages [PromiseKit][PromiseKit], a very widely-adopted framework for elegant handling of asynchronous operations.

### Example: Configure Your App Delegate
```swift
import UIKit
import SwiftlySalesforce

// Global Salesforce variable - in your real-world app
// you could 'inject' it into view controllers instead
var salesforce: Salesforce!

@UIApplicationMain
class AppDelegate: UIApplicationDelegate {

    let consumerKey = "YOUR CONNECTED APP'S CONSUMER KEY HERE"
    let callbackURL = URL(string: "YOUR CONNECTED APP'S CALLBACK URL HERE")!

    var window: UIWindow?
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        salesforce = try! Salesforce(consumerKey: consumerKey, callbackURL: callbackURL)
        return true
    }
}
```
In the example above, we created a `Salesforce` instance with the Connected App's consumer key and callback URL. `salesforce` is an implicitly-unwrapped, optional, global variable, but you could also inject a `Salesforce` instance into your root view controller, for example, instead of using a global variable.

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
let promise: Promise<SObject> = salesforce.retrieve(type: "Account", id: "0013000001FjCcF")
```
And you can add a closure that will be called later, when the promise is fulfilled:
```swift
salesforce.retrieve(type: "Account", id: "0013000001FjCcF").done { (queryResult: QueryResult<SObject>) -> () in
    for record: SObject in queryResult.records {
        // Do something more interesting with each record
        debugPrint(record.type)
    }
}.catch { (error: Error) in
    // Do something with the error
}
```
You can retrieve multiple records in parallel, and wait for them all before proceeding:
```swift
first {
    // (Enclosing this in a ‘first’ block is optional; it keeps things neat.)
    let ids = ["001i0000020i19F", "001i0000034i18A", "001i0000020i22B"]
    return salesforce.retrieve(type: "Account", ids: ids)
}.done { (records: [Record]) -> () in
    for record in records {
        if let name = record.string(forField: "Name"), let modifiedDate = record.date(forField: "LastModifiedDate") {
            debugPrint(name)
            debugPrint(modifiedDate)
        }
    }
}.catch { error in
    // Handle error...
}
```

### Example: Custom Model Objects
Instead of using the generic `SObject`, you could define your own model objects. Swiftly Salesforce will automatically decode the Salesforce response into your model objects, as long as they implement Swift's [`Decodable`](https://developer.apple.com/documentation/swift/decodable) protocol:
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
}.done { (records: [MyAccountModel]) -> () in
    for record in records {
        // Do something more interesting with record data
        let id = record.id
        let name = record.name
        let createdDate = record.createdDate
        let billingAddress = record.billingAddress
        let website = record.website
    }
}.catch { error in
    // Handle error...
}
```

### Example: Update a Salesforce Record
```swift
salesforce.update(type: "Task", id: "00T1500001h3V5NEAU", fields: ["Status": "Completed"]).done { (_) -> () in
    // Update the local model
}.finally {
    // Update the UI
}
```
The `finally` closure will be called regardless of success or failure elsewhere in the promise chain.

You could also use the `SObject` type to update a record in Salesforce. For example:

```swift
// `account` is an SObject we retrieved earlier...
account.setValue("My New Corp.", forField: "Name")
account.setValue(URL(string: "https://www.mynewcorp.com")!, forField: "Website")
account.setValue("123 Main St.", forField: "BillingStreet")
account.setValue(nil, forField: "Sic")
salesforce.update(record: account).done {
    print("Account updated...")
}.catch {
    error in
    // Handle error
}
```

### Example: Query Salesforce
```swift
let soql = "SELECT Id,Name FROM Account WHERE BillingPostalCode = '10024'"
salesforce.query(soql: soql).done { (queryResult: QueryResult) -> () in
    for record in queryResult.records {
        // Do something more interesting with each record
        if let name = record.string(forField: "Name") {
            print("Account name: \(name)")
        }
    }
}.catch { error in
    // Handle the error
}
```

You could also execute multiple queries at once and wait for them all to complete before proceeding:
```swift
first {
    let queries = ["SELECT Name FROM Account", "SELECT Id FROM Contact", "Select Owner.Name FROM Lead"]
    return salesforce.query(soql: queries)
}.done { (queryResults: [QueryResult<SObject>]) -> () in
    // Results are in the same order as the queries
}.catch { error in
    // Handle the error
}
```

### Example: Decode Query Results as Custom Model Objects
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
    salesforce.query(soql: soql).done { (queryResult: QueryResult<Contact>) -> () in
        for contact in queryResult.records {
            // Do something more interesting with each Contact record
            debugPrint(contact.lastName)
            if let account = contact.account {
                // Do something more interesting with each Account record
                debugPrint(account.name)
            }
        }
    }.catch { error in
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
}.then { (result: Data) -> Promise<QueryResult<SObject>> in
    // Query accounts in that zip code
    guard let zip = String(data: result, encoding: .utf8) else {
        throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
    }
    let soql = "SELECT Id,Name FROM Account WHERE BillingPostalCode = '\(zip)'"
    return salesforce.query(soql: soql)
}.done { queryResult -> () in
    for record in queryResult.records {
        if let name = record.string(forField: "Name") {
            print("Account name = \(name)")
        }
    }
}.catch { error in
    // Handle error
}
```
You could repeat this chaining multiple times, feeding the result of one asynchronous operation as the input to the next. Or you could spawn multiple, simultaneous operations and easily specify logic to be executed when all operations complete, or when just the first completes, or when any one operation fails, etc. PromiseKit is an amazingly-powerful framework for handling multiple asynchronous operations that would otherwise be very difficult to coordinate. See [PromiseKit documentation](http://promisekit.org) for more examples.

### Example: Retrieve a User's Photo
```swift
// "first" block is an optional way to make chained calls easier to read...
first {
    salesforce.identity()
}.then { (identity) -> Promise<UIImage> in
    if let photoURL = identity.photoURL {
        return salesforce.fetchImage(url: photoURL)
    }
    else {
        // Return the default image instead
        return Promise(value: defaultImage)
    }
}.done { image in
    self.photoView.image = image
}.catch { (error) -> () in
    // Handle any errors
}.finally {
    self.refreshControl?.endRefreshing()
}
```

### Example: Retrieve a Contact's Photo
```swift	
first {
    salesforce.retrieve(type: "Contact", id: "003f40000027GugAAE")
}.then { (record: Record) -> Promise<UIImage> in
    if let photoPath = record.string(forField: "PhotoUrl") {
        // Fetch image
        return salesforce.fetchImage(path: photoPath)
    }
    else {
        // Return a pre-defined default image
        return Promise(value: self.defaultImage)
    }
}.done { (image: UIImage) -> () in
    // Do something interesting with the image, e.g. display in a view:
    // self.photoView.image = image
}.catch { (error) -> () in
    // Handle any errors
}.finally {
    self.refreshControl?.endRefreshing()
}
```

### Example: Retrieve an Account's Billing Address
Addresses for standard objects, e.g. Account and Contact, are stored in a ['compound' Address field](https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/compound_fields_address.htm), and, if you enable the [geocode data integration rules](https://help.salesforce.com/articleView?id=data_dot_com_clean_admin_clean_rules.htm&language=en_US&type=0) in your org, Salesforce will automatically geocode those addresses, giving you latitude and longitude values you could use for map markers. 
```swift
first {
    salesforce.retrieve(type: "Account", id: "001f40000036J5mAAE")
}.then { (record: Record) -> () in
    if let address = record.address(forField: "BillingAddress"), let lon = address.longitude, let lat = address.latitude {
	// You could put a marker on a map...
        print("LAT/LON: \(lat)/\(lon)")
    }
}.catch { (error) -> () in
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
}.then { (record: MyAccountModel) -> () in
    if let address = record.billingAddress, let lon = address.longitude, let lat = address.latitude {
        // You could put a marker on a map...
        print("LAT/LON: \(lat)/\(lon)")
    }
}.catch { (error) -> () in
    // Handle any errors
}
```

### Example: Handling Errors
```swift
func loadUserInfo() {
    salesforce.identity().compactMap { (identity) -> URL? in
        self.nameLabel.text = identity.displayName
        return identity.photoURL
    }.then { (url) -> Promise<UIImage> in
        salesforce.fetchImage(url: url)
    }.done { image -> () in
        self.photoView.image = image
    }.catch {
        debugPrint("Unable to load user photo! (\($0.localizedDescription))")
    }
}
```

You could also recover from an error, and continue with the chain, using a `recover` closure. The following snippet is from PromiseKit's [documentation](http://promisekit.org/recovering-from-errors):
```swift
CLLocationManager.promise().recover { err in
    guard !err.fatal else { throw err }
    return CLLocationChicago
}.done { location in
    // the user’s location, or Chicago if an error occurred
}.finally { err in
    // the error was fatal
}
```

### Example: Retrieve Object Metadata
If, for example, you want to determine whether the user has permission to update or delete a record so you can disable editing in your UI, or if you want to retrieve all the options in a picklist, rather than hardcoding them in your mobile app, then call `salesforce.describe(type:)` to retrieve an object's [metadata](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_describe.htm):
```swift
first {
    salesforce.describe(type: "Account")
}.done { (accountMetadata) -> () in
    self.saveButton.isEnabled = accountMetadata.isUpdateable
    if let fields = accountMetadata.fields {
        let fieldDict = Dictionary(items: fields, key: { $0.name })
        let industryOptions = fieldDict["Industry"]?.picklistValues
        // Populate a drop-down menu with the picklist values...
    }
}.catch { error in
    debugPrint(error)
}
```

You can retrieve metadata for multiple objects in parallel, and wait for all before proceeding:
```swift
first {
    salesforce.describe(types: ["Account", "Contact", "Task", "CustomObject__c"])
}.then { results -> () in
    // results is an array of ObjectMetadatas, in the same order as requested
}.catch { error in
    // Handle the error
}
```

### Example: Log Out
If you want to log out the current Salesforce user, and then clear any locally-cached data, you could call the following. Swiftly Salesforce will revoke and remove any stored credentials.
```swift
@IBAction func logoutButtonPressed(sender: AnyObject) {
    salesforce.revoke().done {
        debugPrint("Access token revoked.")
    }.ensure {
        self.tasks.removeAll()
        self.tableView.reloadData()
    }.catch {
        debugPrint("Unable to revoke user access token: \($0.localizedDescription)")
    }
}
```

### Example: Search with Salesforce Object Search Language (SOSL)
[Read more about SOSL](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl.htm)
```swift
let sosl = """
    FIND {"A*" OR "B*" OR "C*"} IN Name Fields RETURNING lead(name,phone,Id), contact(name,phone)
"""
salesforce.search(sosl: sosl).done { result in
    debugPrint("Search result count: \(result.searchRecords.count)")
    for record in result.searchRecords {
        // Do something with each record in the search result
    }
}.catch { error in
    // Handle error
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

   [Salesforce.swift]: <SwiftlySalesforce/Classes/Salesforce.swift>
   [Resource.swift]: <SwiftlySalesforce/Classes/Resource.swift>
   [OAuth2Result.swift]: <SwiftlySalesforce/Classes/OAuth2Result.swift>
   [Extensions.swift]: <SwiftlySalesforce/Classes/Extensions.swift>
   [ConnectedApp.swift]: <SwiftlySalesforce/Classes/ConnectedApp.swift>
