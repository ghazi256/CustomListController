Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '13.0'
s.name = "CustomListController"
s.summary = "Display Custom list as popover and popup."
s.requires_arc = true

# 2
s.version = "0.1.0"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "ghazi256" => "ghazi_jaffary@yahoo.com" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/ghazi256/CustomListController"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/ghazi256/CustomListController.git",
             :tag => "#{s.version}" }

# 7
s.framework = "UIKit"

# 8
s.source_files = "CustomListController/Source/*"

# 9
s.resources = "CustomListController/Source/**/*.{xcassets}"

# 10
s.swift_version = "5.0"

end
