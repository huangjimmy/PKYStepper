Pod::Spec.new do |s|
  s.name         = "PKYDropDownStepper"
  s.version      = "0.0.5"
  s.summary      = "UIControl with label & stepper & dropdown list combined"
  s.description  = <<-DESC
                    A customizable UIControl with label & stepper & dropdown selection list combined.
                   DESC
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "yohei okada" => "okada.yohei@gmail.com", "jimmy huang" => "jimmy.s.huang@gmail.com" }
  s.homepage     = "https://github.com/huangjimmy/PKYStepper"
  s.platform     = :ios
  s.ios.deployment_target = "6.0"
  s.source       = { :git => "https://github.com/huangjimmy/PKYStepper.git", :tag => '0.0.4' }
  s.default_subspec     = 'Core'
  s.frameworks = "Foundation", "UIKit", "QuartzCore"
  s.requires_arc = true
 
  s.subspec 'Core' do |ss|
    ss.source_files  = "PKYStepper/**/*.{h,m}"
    ss.frameworks = "Foundation", "UIKit", "QuartzCore"
  end

  s.subspec 'React' do |ss|
    ss.dependency         'PKYDropDownStepper/Core'
    ss.frameworks       = "JavaScriptCore"
    ss.source_files     = "RCTPKYStepper/**/*.{h,m}"
  end
end
