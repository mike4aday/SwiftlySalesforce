Pod::Spec.new do |s|

s.name             = "SwiftlySalesforce"
  s.version          = "3.2.0"
  s.summary          = "An easy-to-use framework for rapid development of native iOS apps with Swift and the Salesforce Platform"


  s.description      = <<-DESC
				An easy-to-use Swift framework for building iOS apps that integrate with the Salesforce Platform. Simplifies Salesforce REST API calls, and OAuth2 authentication.
                       DESC

  s.homepage         = "https://github.com/mike4aday/SwiftlySalesforce"
  s.license          = 'MIT'
  s.author           = { "Michael Epstein" => "@mike4aday" }
  s.source           = { :git => "https://github.com/mike4aday/SwiftlySalesforce.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mike4aday'

  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
  #  'SwiftlySalesforce' => ['Pod/Assets/*.png']
  }

  s.dependency 'PromiseKit', '~> 4.0'
  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'Locksmith', '~> 3.0'

end
