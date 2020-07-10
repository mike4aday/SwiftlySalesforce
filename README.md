
<img src="http://mike4aday.github.io/SwiftlySalesforce/images/SwiftlySalesforceLogo.png" width="76%"/>

<img src="https://img.shields.io/badge/%20in-swift%205.1-orange.svg"/>&nbsp;<img src="https://img.shields.io/cocoapods/p/SwiftlySalesforce.svg?style=flat"/>&nbsp;<img src="https://img.shields.io/github/license/mike4aday/SwiftlySalesforce"/>

Build iOS apps fast on the [Salesforce Platform](http://www.salesforce.com/platform/overview/) with Swiftly Salesforce:
* Written entirely in [Swift](https://developer.apple.com/swift/).
* Uses Swift's new [Combine](https://developer.apple.com/documentation/combine) framework to simplify complex , asynchronous [Salesforce API](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/) interactions.
* Works with [SwiftUI](https://developer.apple.com/documentation/swiftui)
* Manages the Salesforce [OAuth2] user authentication and authorization process (the "OAuth dance") automatically.
* Simpler and lighter alternative to the Salesforce [Mobile SDK for iOS].
* Easy to install and update with Swift Package Manager (SPM)
* Compatible with [Realm](http://realm.io) for a complete, offline mobile solution.
* [See what's new](./CHANGELOG.md).

## Quick Start
You can be up and running in a few minutes by following these steps:

1. [Get a free Salesforce Developer Edition](https://developer.salesforce.com/signup) 
1. Create a Salesforce [Connected App] in your new Developer Edition
1. [Add](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) Swiftly Salesforce to your Xcode project as a package dependency, with URL [https://github.com/mike4aday/SwiftlySalesforce.git](https://github.com/mike4aday/SwiftlySalesforce.git). 

## Minimum Requirements
* iOS 13.0
* Swift 5.1
* Xcode 11

## Examples
Below are some examples that illustrate how to use Swiftly Salesforce. Swiftly Salesforce will automatically manage the entire Salesforce [OAuth2][OAuth2] process (the "OAuth dance"). If Swiftly Salesforce has a valid access token, it will include that token in the header of every API request. If the token has expired, and Salesforce rejects the request, then Swiftly Salesforce will attempt to refresh the access token, without bothering the user to re-enter the username and password. If Swiftly Salesforce doesn't have a valid access token, or is unable to refresh it, then Swiftly Salesforce will direct the user to the Salesforce-hosted login form.

### Example: Setup
You can create a re-usable reference to Salesforce in your `SceneDelegate.swift` file:
```swift
import UIKit
import SwiftUI
import SwiftlySalesforce
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var salesforce: Salesforce!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //...
        // Copy consumer key and callback URL from your Salesforce connected app definition
        let consumerKey = "<YOUR CONNECTED APP'S CONSUMER KEY HERE>"
        let callbackURL = URL(string: "<YOUR CONNECTED APP'S CALLBACK URL HERE>")!
        let connectedApp = ConnectedApp(consumerKey: consumerKey, callbackURL: callbackURL)
        salesforce = Salesforce(connectedApp: connectedApp)
    }
    
    //...
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
Note that `retrieve` is an asynchronous function, whose return value is a [Combine publisher](https://developer.apple.com/documentation/combine/publisher):
```swift
let pub: AnyPublisher<SObject, Error> = salesforce.retrieve(type: "Account", id: "0013000001FjCcF")
```
And you could use the `sink` subscriber to [handle the result](https://developer.apple.com/documentation/combine/receiving_and_handling_events_with_combine):
```swift
let subscription = salesforce.retrieve(object: "Account", id: "0013000001FjCcF")
.sink(receiveCompletion: { (completion) in
    switch completion {
    case .finished:
        print("Done")
    case let .failure(error):
        //TODO: handle the error
        print(error)
    }
}, receiveValue: { (record) in
    //TODO: something more interesting with the result
    if let name = record.string(forField: "Name") {
        print(name)
    }
})
```
You can retrieve multiple records in parallel, and wait for them all before proceeding:
```swift
var subscriptions = Set<AnyCancellable>()
//...
let pub1 = salesforce.retrieve(object: "Account", id: "0013000001FjCcF")
let pub2 = salesforce.retrieve(object: "Contact", id: "0034000002AdCdD")
let pub3 = salesforce.retrieve(object: "Opportunity", id: "0065000002AdNdH")
pub1.zip(pub2, pub3).sink(receiveCompletion: { (completion) in
    //TODO:
}) { (account, contact, opportunity) in
    //TODO
}.store(in: &subscriptions)
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
let pub: AnyPublisher<MyAccountModel, Error> = salesforce.retrieve(object: "Account", id: "0013000001FjCcF")
```

### Example: Update a Salesforce Record
```swift
salesforce.update(object: "Task", id: "00T1500001h3V5NEAU", fields: ["Status": "Completed"])
    .sink(receiveCompletion: { (completion) in
        //TODO: handle completion
    }) { _ in
        //TODO: successfully updated
    }.store(in: &subscriptions)
```

You could also use the generic `SObject` (typealias for `SwiftlySalesforce.Record`) to update a record in Salesforce. For example:

```swift
// `account` is an SObject we retrieved earlier...
account.setValue("My New Corp.", forField: "Name")
account.setValue(URL(string: "https://www.mynewcorp.com")!, forField: "Website")
account.setValue("123 Main St.", forField: "BillingStreet")
account.setValue(nil, forField: "Sic")
salesforce.update(record: account)
    .sink(receiveCompletion: { (completion) in
        //TODO: handle completion
    }) { _ in
        //TODO: successfully updated
    }
    .store(in: &subscriptions)
```

### Example: Query Salesforce
```swift
let soql = "SELECT Id,Name FROM Account WHERE BillingPostalCode = '10024'"
salesforce.query(soql: soql)
    .sink(receiveCompletion: { (completion) in
        //TODO: completed
    }) { (queryResult: QueryResult<SObject>) in
        for record in queryResult.records {
            if let name = record.string(forField: "Name") {
                print(name)
            }
        }
    }
    .store(in: &subscriptions)
```

### Example: Decode Query Results as Your Custom Model Objects
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
    salesforce.query(soql: soql)
        .sink(receiveCompletion: { (completion) in
            //TODO: completed
        }) { (queryResult: QueryResult<Contact>) in
            for contact in queryResult.records {
                print(contact.lastName)
                if let account = contact.account {
                    print(account.name)
                }
            }
        }
        .store(in: &subscriptions)
    }
```

### Example: Retrieve Object Metadata
If, for example, you want to determine whether the user has permission to update or delete a record so you can disable editing in your UI, or if you want to retrieve all the options in a picklist, rather than hardcoding them in your mobile app, then call `salesforce.describe(type:)` to retrieve an object's [metadata](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_describe.htm):
```swift
salesforce.describe(object: "Account")
    .sink(receiveCompletion: { (completion) in
        //TODO: completed
    }) { (acctMetadata) in
        //TODO: update UI
        let editable = acctMetadata.isUpdateable
    }
    .store(in: &subscriptions)
```

### Example: Log Out
If you want to log out the current Salesforce user, and then clear any locally-cached data, you could call the following. Swiftly Salesforce will revoke and remove any stored credentials.
```swift
let pub: AnyPublisher<Void, Error> = salesforce.logOut()
//TODO: Connect to UI element with SwiftUI
```

### Example: Search with Salesforce Object Search Language (SOSL)
[Read more about SOSL](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl.htm)
```swift
let sosl = """
    FIND {"A*" OR "B*" OR "C*" OR "D*"} IN Name Fields RETURNING Lead(name,phone,Id), Contact(name,phone)
"""
salesforce.search(sosl: sosl)
    .sink(receiveCompletion: { (completion) in
        //TODO: completed
    }) { (results: [SObject]) in
        for result in results {
           print("Object type: \(result.object)")
        }
    }
    .store(in: &subscriptions)
```

## Resources
If you're new to the Salesforce Platform or the Salesforce REST API, you might find the following resources useful:
* [Salesforce REST API Developer's Guide][REST API]
* [Salesforce Platform](http://www.salesforce.com/platform)
* [Salesforce Developers](https://developer.salesforce.com): official Salesforce developers' site; training, documentation, SDKs, etc.
* [Salesforce Partner Community](https://partners.salesforce.com): "Innovate, grow, connect" with Salesforce ISVs. Join the [Salesforce + iOS Mobile][sfdc-ios Chatter] Chatter group
* [Salesforce Mobile SDK for iOS][Mobile SDK for iOS]: Salesforce-supported SDK for developing mobile apps. Written in Objective-C. Available for [Android](https://github.com/forcedotcom/SalesforceMobileSDK-Android), too
* [Use of Salesforce for Android and iOS platform versus creation of custom app](https://help.salesforce.com/HTViewSolution?id=000192840&language=en_US)

## Contact
Questions, suggestions, bug reports and code contributions welcome:
* Open a [GitHub issue](https://github.com/mike4aday/SwiftlySalesforce/issues)
* Twitter [@mike4aday]
* Join the Salesforce [Partner Community] and post to the '[Salesforce + iOS Mobile][sfdc-ios Chatter]' Chatter group

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
