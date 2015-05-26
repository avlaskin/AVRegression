#
#  Be sure to run `pod spec lint AVRegression.podspec' to ensure this is a

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "AVRegression"
  s.version      = "0.1.1"
  s.summary      = "Polynomial and linear regression using Accelerate framework (vecLib)."

  s.description  = <<-DESC
                   Polynomial and linear regression using Accelerate framework (vecLib).
                   Inspired by Coursera Machine Learning course.                   
                   DESC

  s.homepage     = "http://github.com/avlaskin/AVRegression"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  
  s.author             = { "Alexey Vlaskin" => "alex@avlaskin.com" }
  s.social_media_url   = "http://twitter.com/avlaskin"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "8.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/avlaskin/AVRegression.git", :tag => "0.1.1" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "AVRegression", "AVRegression/**/*.{h,m}"
  s.public_header_files = "AVRegression/**/*.h"

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.framework  = "Accelerate"
  
  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true

end
