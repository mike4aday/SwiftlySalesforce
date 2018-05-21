Pod::Spec.new do |s|

s.name             = "SwiftlySalesforce"
s.version          = "6.0.7"
s.summary          = "A Swift framework for the rapid development of native iOS apps on the Salesforce Platform"


  s.description      = <<-DESC
				An easy-to-use Swift framework for building iOS apps that integrate with the Salesforce Platform. Swiftly Salesforce uses 'promises' to simplify Salesforce REST API calls, and OAuth2 authentication.
                       DESC

  s.homepage         = "https://github.com/mike4aday/SwiftlySalesforce"
  s.license          = 'MIT'
  s.author           = { "Michael Epstein" => "@mike4aday" }
  s.source           = { :git => "https://github.com/mike4aday/SwiftlySalesforce.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mike4aday'

  s.platform     = :ios, '10.3'
  s.requires_arc = true

  s.source_files = 'SwiftlySalesforce/Classes/**/*'
  s.resource_bundles = {

  }

  s.dependency 'PromiseKit', '~> 4.0'

end
