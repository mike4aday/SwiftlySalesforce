Pod::Spec.new do |s|
  s.name             = "SwiftlySalesforce"
  s.version          = "2.0.1"
  s.summary          = "An easy-to-use framework for rapid development of native iOS apps with Swift and the Salesforce Platform"


  s.description      = <<-DESC
				An easy-to-use framework, written in Swift 2, for building iOS apps that integrate with the Salesforce Platform. Simplifies Salesforce REST API calls, and OAuth2 authentication.
                       DESC

  s.homepage         = "https://github.com/mike4aday/SwiftlySalesforce"
  s.license          = 'MIT'
  s.author           = { "Michael Epstein" => "@mike4aday" }
  s.source           = { :git => "https://github.com/mike4aday/SwiftlySalesforce.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mike4aday'

  s.platform     = :ios, '9.1'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SwiftlySalesforce' => ['Pod/Assets/*.png']
  }

  s.dependency 'PromiseKit', '~> 3.2.1'
  s.dependency 'Alamofire', '~> 3.0'
  s.dependency 'Locksmith', '~> 2.0'
end
