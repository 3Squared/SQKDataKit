Pod::Spec.new do |s|

  s.name         = "SQKDataKit"
  s.version      = "0.2.5"
  s.summary      = "Lightweight Core Data helper to reduce boilerplate code."

  s.license = { :type => 'Custom', :file => 'LICENCE' }

  s.description  = <<-DESC
                   A longer description of SQKDataKit in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://git.3squared.com/ios-libraries/sqkdatakit"

  s.authors      = { "Luke Stringer" => "luke.stringer@3squared.com", "Sam Oakley" => "sam.oakley@3squared.com", "Zack Brown" => "zack.brown@3squared.com", "Ken Boucher" => "ken.boucher@3squared.com", "Ste Prescott" => "ste.prescott@3squared.com", "Ben Walker" => "ben.walter@3squared.com"}

  s.osx.platform    = :osx, '10.9' 
  s.ios.platform    = :ios, '6.0'

  s.source       = { :git => "git@git.3squared.com:ios-libraries/sqkdatakit.git", :tag => "#{s.version}" }

  s.source_files  = 'Classes/**/*{h,m}'
  s.public_header_files = ["Classes/NSManagedObject+SQKAdditions.h", "Classes/SQKContextManager.h", "Classes/SQKDataImportOperation.h", "Classes/SQKDataKit.h"]

  s.framework  = 'CoreData'

  s.requires_arc = true

end
