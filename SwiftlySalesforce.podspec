Pod::Spec.new do |s|

s.name             = "SwiftlySalesforce"
s.version          = "7.1.6"
s.summary          = "The swiftest way to build iOS apps that connect to Salesforce."

  s.description      = <<-DESC
				An easy-to-use Swift framework for building iOS apps that integrate with the Salesforce Platform. Swiftly Salesforce uses 'promises' to simplify Salesforce REST API calls, and OAuth2 authentication.
                       DESC

  s.homepage         = "https://github.com/mike4aday/SwiftlySalesforce"
  s.license          = 'MIT'
  s.author           = { "Michael Epstein" => "@mike4aday" }
  s.source           = { :git => "https://github.com/mike4aday/SwiftlySalesforce.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mike4aday'

  s.platform     = :ios, '11.3'
  s.requires_arc = true

  s.source_files = 'SwiftlySalesforce/Sources/**/*.swift'
  s.resource_bundles = {

  }

  s.dependency 'PromiseKit/CorePromise', '~> 6.0'

end
