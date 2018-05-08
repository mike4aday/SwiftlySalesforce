# Change Log

## Version 6.0.6 (May 8, 2018)
Resolves [issue #70](https://github.com/mike4aday/SwiftlySalesforce/issues/70). Thanks to [@hmuronaka](https://github.com/hmuronaka) for [pull request](https://github.com/mike4aday/SwiftlySalesforce/pull/71).

## Version 6.0.5 (Apr. 12, 2018)
Fixed error in identity method's response handler. (Resolves [issue #60](https://github.com/mike4aday/SwiftlySalesforce/issues/60).)

## Version 6.0.4 (Mar. 1, 2018)
Change access to `ConnectedApp.revoke` method from `internal` to `public`.

## Version 6.0.3 (Jan. 23, 2018)
Replace '+' with '%2B' in URLRequest.queryParameters. (Resolves [issue #58](https://github.com/mike4aday/SwiftlySalesforce/issues/58).) Thanks to [@hmuronaka](https://github.com/hmuronaka) for [pull request](https://github.com/mike4aday/SwiftlySalesforce/pull/59).

## Version 6.0.2 (Jan. 11, 2018)
- Clear token from secure storage after revocation ([issue #57](https://github.com/mike4aday/SwiftlySalesforce/issues/57)).
- Fixed error in revocation endpoint URL. (Thanks to [@daichi1021](https://github.com/daichi1021) for [pull request](https://github.com/mike4aday/SwiftlySalesforce/pull/56).)

## Version 6.0.1 (Dec. 7, 2017)
Fixed bug in `Salesorce.apex` and `Salesforce.custom` methods so that callers can now set the HTTP body data.

## Version 6.0.0 (Nov. 5, 2017)
This release contains breaking changes. See [README](https://github.com/mike4aday/SwiftlySalesforce/blob/master/README.md) and [documentation](http://cocoadocs.org/docsets/SwiftlySalesforce).
Highlights of changes and improvements:
- Incorporated Swift 4's new `Codable` protocol (i.e. `Decodable` and `Encodable` throughout. This simplifies both Swiftly Salesforce's code and the creation of your own models that represent Salesforce objects.
- Simpler and faster to incorporate Swiftly Salesforce in your apps.
- New `Record` type to represent generic Salesforce object records, replaces `SObject` from version 5.0.0. If you prefer, you could create your own model objects and use those instead, via the magic of Swift generics and the new `Codable` protocol. See the [README](https://github.com/mike4aday/SwiftlySalesforce/blob/master/README.md) and example app for samples.
- New `Organization` type holds information about the Salesforce "org." Call `salesforce.org( )` to retrieve org information.
- References to `redirectURL` replaced with `callbackURL` to be consistent with Salesforce [Connected App](https://help.salesforce.com/articleView?id=connected_app_overview.htm&type=0) terminology.
- More and better test coverage.

## Version 5.0.0 (Oct. 15, 2017)
This release contains breaking changes. See [README](https://github.com/mike4aday/SwiftlySalesforce/blob/master/README.md) and [documentation](http://cocoadocs.org/docsets/SwiftlySalesforce).
Highlights of changes and improvements:
- Incorporated Swift 4's new `Decodable` protocol throughout. This simplifies both Swiftly Salesforce's code and the creation of your own models that represent Salesforce objects.
- New `SObject` type to represent a generic Salesforce objects. If you prefer, you can create your own model objects and use those instead, via the magic of Swift generics and the new `Decodable` protocol. See the [README](https://github.com/mike4aday/SwiftlySalesforce/blob/master/README.md) and example app for samples.
- Revamped Error types.
- More and better test coverage.

## Version 4.0.6 (Sep. 28, 2017)
- Removed Alamofire dependency
- Increased test coverage

## Version 4.0.5 (Sep. 10, 2017)
- Added Keychain wrapper class
- Removed Locksmith dependency

## Version 4.0.4 (Sep. 5, 2017)
Support Swift 4 

## Version 4.0.3 (Aug. 5, 2017) 
Changed access level of `Address` members to explicitly `public` (were implicitly `internal`)

## Version 4.0.2 (July 30, 2017)
Fixed misspelling in enum `Address.GeocodeAccuracy` ([issue #44](https://github.com/mike4aday/SwiftlySalesforce/issues/44))

## Version 4.0.1 (July 17, 2017)
Documentation updates

## Version 4.0.0 (July 14, 2017)
This release contains breaking changes. See [README](https://github.com/mike4aday/SwiftlySalesforce/blob/master/README.md) and [documentation](http://cocoadocs.org/docsets/SwiftlySalesforce).
Highlights of changes and improvements:
- Removed the `salesforce` singleton (you could still instantiate your own global `salesforce` variable, if you like; see [example](https://github.com/mike4aday/SwiftlySalesforce/blob/master/Example/SwiftlySalesforce/AppDelegate.swift)).
- `Salesforce` now instantiated with new `ConnectedApp` class. See [README](./README.md#example-configure-your-app-delegate).
- Supports switching among multiple users and securely storing their access & refresh tokens.
- `Salesforce.apexREST` method renamed `Salesforce.apex`, and now returns `Promise<Data>` (instead of `Promise<Any>`). 
- New `Salesforce.fetchImage` methods to get relatively-small images, such as user thumbnails or Contact photos ([issue #33](https://github.com/mike4aday/SwiftlySalesforce/issues/33) and [issue #35](https://github.com/mike4aday/SwiftlySalesforce/issues/35)).
- New `Address` struct to hold standard, compound address fields, including longitude and latitude ([issue #38](https://github.com/mike4aday/SwiftlySalesforce/issues/38) and [issue #39](https://github.com/mike4aday/SwiftlySalesforce/issues/39)).

## Version 3.6.0 (Jun. 17, 2017)
Updated the default Salesforce API version to 40.0 (Summer '17)

## Version 3.5.1 (Jun. 7, 2017)
Fixes [issue #29](https://github.com/mike4aday/SwiftlySalesforce/issues/29).

## Version 3.5.0 (Apr. 26, 2017)
- Updated the default Salesforce API version to 39.0 (Spring '17).
- Added method `Salesforce.describeAll()` to retrieve metadata about all objects defined in the org ([issue #28](https://github.com/mike4aday/SwiftlySalesforce/issues/28)).
- Bug fix; `ObjectDescription.keyPrefix` now returns an empty string if the retrieved object metadata value is null. (In the next major release `keyPrefix` will become an optional string.) ([issue #36](https://github.com/mike4aday/SwiftlySalesforce/issues/36))
- `ObjectDescription.fields` now returns an empty dictionary if the retrieved metadata has no field-level information, as is the case with `Salesforce.describeAll()`. (In the next major release, `fields` will become an optional dictionary.)
- Bug fix; `Salesforce.limits()` broke with the Salesforce Spring '17 release, which changed the JSON payload returned by the REST API's `limits` resource ([issue #37](https://github.com/mike4aday/SwiftlySalesforce/issues/37)).
- `Model.UserInfo` and `Model.QueryResult` now have public initializers ([issue #34](https://github.com/mike4aday/SwiftlySalesforce/issues/34)).

## Version 3.4.0 (Feb. 26, 2017)
Support for registering with Salesforce notification services.
(Thanks to [@quintonwall](https://github.com/quintonwall) for [pull request](https://github.com/mike4aday/SwiftlySalesforce/pull/24).)

## Version 3.3.2 (Feb. 7, 2017)
Support Carthage dependency manager

## Version 3.3.1 (Jan. 10, 2017)
Updated README

## Version 3.3.0 (Jan. 6, 2017)
- Added overloaded `Salesforce.retrieve` method to retrieve multiple records in parallel
- Added overloaded `Salesforce.query` method to execute multiple SOQL queries in parallel
- Added overloaded `Salesforce.describe` method to retrieve metadata about multiple Salesforce objects in parallel
- Additional documentation, tests and test coverage

## Version 3.2.0 (Dec. 14, 2016)
- Added Salesforce.describe( ) method, and corresponding [model](https://github.com/mike4aday/SwiftlySalesforce/blob/master/Pod/Classes/Model.swift) structs (ObjectDescription, FieldDescription, PicklistValue) for retrieving [object metadata](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_describe.htm). (Closes [issue #13](https://github.com/mike4aday/SwiftlySalesforce/issues/13).)
- Additional tests and test coverage

## Version 3.1.1 (Nov. 23, 2016)
Fixed issue #15; removed unneeded `id` parameter in `Salesforce.insert( )` method

## Version 3.1.0 (Nov. 16, 2016)
- Updated `LoginDelegate` to accommodate custom login view controllers and flows. Note: the default [OAuth2 user-agent flow](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_understanding_user_agent_oauth_flow.htm) with the Salesforce-hosted webform is the recommended way to authenticate users; your app shouldn't handle their credentials. Adapted from [@hmuronaka's pull request](https://github.com/mike4aday/SwiftlySalesforce/pull/14).
- Deprecated `LoginDelegate` extension method `handleRedirectURL(redirectURL: URL)` in favor of `handleRedirectURL(url: URL)`.

## Version 3.0.1 (Oct. 27, 2016)
Added file "OAuth2.plist" which is used for testing the framework. If you run the tests, edit the file and insert your own values for the Salesforce access token, refresh token, etc. 

## Version 3.0.0 (Oct. 25, 2016)
(This is a ‘breaking’ change that is not compatible with prior versions)
- Upgrade for Swift 3
- Lots of enhancements to make building native iOS apps on Salesforce even easier - see the [README](./README.md)

## Version 2.2.0 (Oct. 24, 2016)
- Support for custom login view controllers - [thanks to @humoronaka](https://github.com/mike4aday/SwiftlySalesforce/pull/10). (Note: this feature will not be carried over into version 3.0.0, which is nearly complete as of Oct. 24, 2016, but will be incorporated into a subsequent release.)

## Version 2.1.0 (Oct. 1, 2016)
- Updated code for Swift 2.3
- Updated Podfile for Xcode 8

## Version 2.0.1 (Aug. 4, 2016)
- Updated README
- Updated PromiseKit dependency to version 3.2.1+
- Updated SalesforceAPI.DefaultVersion to 37.0
- Replaced deprecated selector string syntax with Swift #selector
- Fixed issue #1 (irrelevant comments)

## Version 2.0.0 (Mar. 5, 2016)
- Incorporated PromiseKit for asynchronous interaction with Salesforce REST API and OAuth2 endpoints
- Updated SalesforceAPI.DefaultVersion to 36.0
- Added ApexRest to SalesforceAPI enum
- Simplified Alamofire extension

## Version 1.0.3 (Jan. 14, 2016)
Updated README

## Version 1.0.2 (Jan. 11, 2016)
Updated README

## Version 1.0.1 (Jan. 8, 2016)
Updated example files

## Version 1.0.0 (Jan. 7, 2016)
Initial release
