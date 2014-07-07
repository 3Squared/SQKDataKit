Pod::Spec.new do |s|

	s.name         = "SQKDataKit"
	s.version      = "0.4.0"
	s.summary      = "Lightweight Core Data helper to reduce boilerplate code."

	s.license = { :type => 'Custom', :file => 'LICENCE' }

	s.description  = <<-DESC
									Collection of classes to make working with Core Data easier and help DRY-up your code.
									Provides convenience methods and classes for working in a multi-threaded environment with NSManagedObjects and NSManagedObjectContexts. 
									Codifies some good practises for importing large data sets efficiently.
									DESC

	s.homepage     = "http://git.3squared.com/ios-libraries/sqkdatakit"

	s.authors      = { "Luke Stringer" => "luke.stringer@3squared.com", "Sam Oakley" => "sam.oakley@3squared.com", "Zack Brown" => "zack.brown@3squared.com", "Ken Boucher" => "ken.boucher@3squared.com", "Ste Prescott" => "ste.prescott@3squared.com", "Ben Walker" => "ben.walker@3squared.com"}

	s.osx.platform    = :osx, '10.9' 
	s.ios.platform    = :ios, '6.0'
	s.ios.deployment_target = '6.0'
	s.osx.deployment_target = '10.9' 

	s.source       = { :git => "git@git.3squared.com:ios-libraries/sqkdatakit.git", :tag => "#{s.version}" }

	s.ios.source_files  = ["Classes/shared/**/*{h,m}", "Classes/ios/**/*{h,m}"]
	s.osx.source_files  = ["Classes/shared/**/*{h,m}", "Classes/osx/**/*{h,m}"]

	s.public_header_files = ["Classes/shared/SQKManagedObjectController.h", "Classes/shared/NSManagedObject+SQKAdditions.h", "Classes/shared/SQKContextManager.h", "Classes/shared/SQKCoreDataOperation.h", "Classes/shared/SQKDataKit.h", "Classes/shared/NSManagedObjectContext+SQKAdditions.h", "Classes/ios/SQKFetchedTableViewController.h"]

	s.framework  = 'CoreData'

	s.requires_arc = true

end
