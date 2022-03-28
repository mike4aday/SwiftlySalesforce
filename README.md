<img src="https://mike4aday.github.io/SwiftlySalesforce/images/Swiftly-Salesforce-Logo.svg" width="88px"/> 

# Swiftly Salesforce

"The Swift-est way to build native mobile apps that connect to [Salesforce](https://www.salesforce.com/products/platform/overview/)."

<img src="https://img.shields.io/badge/%20in-swift%205.5-orange.svg"/>&nbsp;<img src="https://img.shields.io/cocoapods/p/SwiftlySalesforce.svg?style=flat"/>&nbsp;<img src="https://img.shields.io/github/license/mike4aday/SwiftlySalesforce"/>

* Written entirely in [Swift](https://developer.apple.com/swift/).
* Very easy to install and update with [Swift Package Manager](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app).
* Built with Apple's new [Swift concurrency](https://developer.apple.com/news/?id=2o3euotz) model to simplify complex, asynchronous calls to the [Salesforce REST API](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/).
* Designed for [SwiftUI](https://developer.apple.com/documentation/swiftui/), the modern, declarative way to build iOS apps.
* Manages the Salesforce [user authorization flows](https://help.salesforce.com/articleView?id=sf.remoteaccess_oauth_flows.htm&type=5) automatically.
* Pair with [Core Data](https://developer.apple.com/documentation/coredata) for a complete offline mobile solution.
* Simpler and lighter alternative to the Salesforce [Mobile SDK for iOS](https://github.com/forcedotcom/SalesforceMobileSDK-iOS).
* See [what's new](./CHANGELOG.md) in this release.

## Minimum Requirements
* iOS 15.0
* Swift 5.5
* Xcode 13

## Quick Start
Get up and running in a few minutes:
1. [Get a free Salesforce Developer Edition](https://developer.salesforce.com/signup) environment.
1. [Create a Connected App](https://help.salesforce.com/articleView?id=sf.connected_app_create.htm&type=5) in your new environment. ([Example](https://mike4aday.github.io/SwiftlySalesforce/images/ConnectedAppDefinition.png))
1. [Add](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) the Swiftly Salesforce package to your Xcode project with URL https://github.com/mike4aday/SwiftlySalesforce.git. 

Check out this [screenshot](https://mike4aday.github.io/SwiftlySalesforce/images/ConnectedAppDefinition.png) for an example Connected App definition. Note that the checkbox for "Require Secret for Refresh Token Flow" should *not* be selected.

## Sample App
Check out [MySalesforceAccounts](https://github.com/mike4aday/MySalesforceAccounts) for a complete, working app that uses [SwiftUI](https://developer.apple.com/documentation/swiftui/), [Swift concurrency](https://developer.apple.com/news/?id=2o3euotz) and Swiftly Salesforce to display the user's Salesforce account records. Though it's a relatively-trival app, it illustrates how to configure an app and quickly connect it to Salesforce.

Before you run the sample app, edit [Salesforce.json](https://github.com/mike4aday/MySalesforceAccounts/blob/2fa839ad30155d384712c3b155dddb2ed19119b8/MySalesforceAccounts/Salesforce.json) and replace the temporary values for the consumer key and callback URL with those of your own Connected App.

## Documentation
Comning soon.

## User Authorization
Swiftly Salesforce will automatically manage all required Salesforce [authorization flows](https://help.salesforce.com/articleView?id=sf.remoteaccess_oauth_flows.htm&type=5). If Swiftly Salesforce already has a valid access token in its secure  store, it will include that token in the header of every API request. If the token has expired and Salesforce rejects the request, then Swiftly Salesforce will attempt to refresh the access token without bothering the user to re-enter the username and password. If Swiftly Salesforce doesn't have a valid access token, or is unable to refresh it, then Swiftly Salesforce will direct the user to the Salesforce-hosted login form. 

## Questions, Suggestions & Bug Reports
* Open a [GitHub issue](https://github.com/mike4aday/SwiftlySalesforce/issues/new)
* Send me a direct message on Twitter [@mike4aday](https://twitter.com/mike4aday)
* Send me a message on LinkedIn [in/mike4aday](https://www.linkedin.com/in/mike4aday)
