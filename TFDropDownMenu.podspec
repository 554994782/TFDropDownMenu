
Pod::Spec.new do |s|

  s.name         = "TFDropDownMenu"
  s.version      = "1.0.2"
  s.summary      = "Have no summary TFDropDownMenu."

  s.description  = <<-DESC
                   A Main Foundation Component for Other Kit
                   DESC

  s.homepage     = "https://github.com/554994782/TFDropDownMenu.git"

  s.license      = "MIT"

  s.author       = { "jiangyunfeng" => "554994782@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/554994782/TFDropDownMenu.git", :tag => s.version }

s.source_files  = 'TFDropDownMenu/**/*.{h,m}'

s.subspec "Custom" do |ss|
ss.source_files = "TFDropDownMenu/Custom/*.{h,swift,c,m}"
end

s.public_header_files = "TFDropDownMenu/**/*.h"
s.dependency 'Masonry'
end
