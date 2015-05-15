Pod::Spec.new do |s|
  s.name         = "UIClosures"
  s.version      = "0.0.2"
  s.summary      = "Swift closure library for UIKit"

  s.description  = <<-DESC
		Closure based UI events. Supports UIControls and UIGestureRecognizers. Written purely in Swift and memory managed. Cheers
		      DESC
  s.homepage     = "https://github.com/arkverse/UIClosures"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Zaid Daghestani" => "zaid@arkverse.com" }
  s.social_media_url   = "http://twitter.com/arkverse"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/arkverse/UIClosures.git", :tag => "v#{s.version}" }
  s.source_files  = "Classes", "Classes/**/*.{swift}"
  s.requires_arc = true
end
