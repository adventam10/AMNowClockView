Pod::Spec.new do |s|
    s.name         = "AMNowClockView"
    s.version      = "2.1"
    s.summary      = "AMNowClockView is a view can display current time."
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.homepage     = "https://github.com/adventam10/AMNowClockView"
    s.author       = { "am10" => "adventam10@gmail.com" }
    s.source       = { :git => "https://github.com/adventam10/AMNowClockView.git", :tag => "#{s.version}" }
    s.platform     = :ios, "9.0"
    s.requires_arc = true
    s.source_files = 'AMNowClock/*.{swift}'
    s.swift_version = "5.0"
end

