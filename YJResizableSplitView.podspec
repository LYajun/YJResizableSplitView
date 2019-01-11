Pod::Spec.new do |s|

  s.name         = "YJResizableSplitView"
  s.version      = "1.0.0"
  s.summary      = "分屏视图"

  s.homepage     = "https://github.com/LYajun/YJResizableSplitView"
  

  s.license      = "MIT"


  s.author             = { "刘亚军" => "liuyajun1999@icloud.com" }
 
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = '8.0'

  s.source       = { :git => "https://github.com/LYajun/YJResizableSplitView.git", :tag => s.version }

  s.source_files  = "YJResizableSplitView/*.{h,m}"

  s.resources = "YJResizableSplitView/YJResizableSplitView.bundle"

  s.requires_arc = true
  s.dependency 'Masonry'


end
