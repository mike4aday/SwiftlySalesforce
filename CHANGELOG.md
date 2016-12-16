# Change Log

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
