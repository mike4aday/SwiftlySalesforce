# Swiftly Salesforce

<img src="https://img.shields.io/badge/%20in-swift%205.3-orange.svg"/>&nbsp;<img src="https://img.shields.io/cocoapods/p/SwiftlySalesforce.svg?style=flat"/>&nbsp;<img src="https://img.shields.io/github/license/mike4aday/SwiftlySalesforce"/>

Swiftly Salesforce is the Swift-est way to build native mobile apps that connect to [Salesforce](https://www.salesforce.com/products/platform/overview/):
* Written entirely in [Swift](https://developer.apple.com/swift/).
* Built with Apple's [Combine](https://developer.apple.com/documentation/combine) framework to simplify complex, asynchronous calls to the [Salesforce REST API](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/).
* Works great with [SwiftUI](https://developer.apple.com/documentation/swiftui/), the modern, declarative way to build iOS apps.
* Manages the Salesforce [user authorization flows](https://help.salesforce.com/articleView?id=sf.remoteaccess_oauth_flows.htm&type=5) automatically.
* Pair with [Core Data](https://developer.apple.com/documentation/coredata) for a complete offline mobile solution.
* Easy to install, update and debug with [Xcode](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app).
* Simpler and lighter alternative to the Salesforce [Mobile SDK for iOS].
* See [what's new](./CHANGELOG.md) in this release.

## Minimum Requirements
* iOS 14.0
* Swift 5.3
* Xcode 12

## Quick Start
Get up and running in a few minutes:
1. [Get a free Salesforce Developer Edition](https://developer.salesforce.com/signup) environment.
1. [Create a Connected App](https://help.salesforce.com/articleView?id=sf.connected_app_create.htm&type=5) in your new environment.
1. [Add](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) the Swiftly Salesforce package to your Xcode project with URL https://github.com/mike4aday/SwiftlySalesforce.git. 

Check out this screenshot for an example Connected App definition. Note that "Require Secret for Refresh Token Flow" should *not* be selected.

## User Authorization
Swiftly Salesforce will automatically manage all required Salesforce [authorization flows](https://help.salesforce.com/articleView?id=sf.remoteaccess_oauth_flows.htm&type=5). If Swiftly Salesforce already has a valid access token in its secure  store, it will include that token in the header of every API request. If the token has expired and Salesforce rejects the request, then Swiftly Salesforce will attempt to refresh the access token without bothering the user to re-enter the username and password. If Swiftly Salesforce doesn't have a valid access token, or is unable to refresh it, then Swiftly Salesforce will direct the user to the Salesforce-hosted login form. 

You could modify this default authorization behavior if you don't want the user interrupted by the authentication form. Many methods have an argument, `allowsLogin`, which is `true` by default ([example](https://github.com/mike4aday/SwiftlySalesforce/blob/6134e06e46f333a7398915f2fce2e80d51475dac/Sources/SwiftlySalesforce/ConnectedApp%2BQuery.swift#L71)). But if you'd set `allowsLogin` to `false`, Swiftly Salesforce would attempt to refresh the token without interrupting the user, and if that attempt is unsuccessful the call would fail. The user would not be prompted for the username and password, and you could catch the resulting [error](https://github.com/mike4aday/SwiftlySalesforce/blob/9d7bbf08c4ea9ba1edd8d0428df280ad9f944a35/Sources/SwiftlySalesforce/SalesforceError.swift#L21) and handle it as you see fit.

## Sample App
Check out [MySalesforceAccounts](https://github.com/mike4aday/MySalesforceAccounts) for a complete, working app that uses [SwiftUI](https://developer.apple.com/documentation/swiftui/), [Combine](https://developer.apple.com/documentation/combine) and Swiftly Salesforce to display the user's Salesforce account records. Though it's a relatively-trival app, it illustrates how to configure an app and quickly connect it to Salesforce. See especially [MyAccountsLoader.swift](https://github.com/mike4aday/MySalesforceAccounts/blob/6e4e0f864c79c62b0b77009ce3d0122218320a01/MySalesforceAccounts/MyAccountsLoader.swift), [ContentView.swift](https://github.com/mike4aday/MySalesforceAccounts/blob/6e4e0f864c79c62b0b77009ce3d0122218320a01/MySalesforceAccounts/ContentView.swift) and [Salesforce.json](https://github.com/mike4aday/MySalesforceAccounts/blob/6e4e0f864c79c62b0b77009ce3d0122218320a01/MySalesforceAccounts/Salesforce.json).

## Questions, Suggestions & Bug Reports
* Open a [GitHub issue](https://github.com/mike4aday/SwiftlySalesforce/issues/new)
* Twitter [@mike4aday](https://twitter.com/mike4aday)
