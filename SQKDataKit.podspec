Pod::Spec.new do |s|

	s.name         = 'SQKDataKit'
	s.version      = '1.2.1'
	s.summary      = 'Lightweight Core Data helper to reduce boilerplate code.'

	s.license = { :type => 'Custom', :file => 'LICENCE' }

	s.description  = <<-DESC
									Collection of classes to make working with Core Data easier and help DRY-up your code.
									Provides convenience methods and classes for working in a multi-threaded environment with NSManagedObjects and NSManagedObjectContexts.
									Codifies some good practises for importing large data sets efficiently.
									DESC


	s.homepage     = 'https://github.com/3squared/SQKDataKit'
	s.authors      = { 'Luke Stringer' => 'luke.stringer@3squared.com', 'Sam Oakley' => 'sam.oakley@3squared.com', 'Zack Brown' => 'zack.brown@3squared.com', 'Ken Boucher' => 'info@3squared.com', 'Ste Prescott' => 'info@3squared.com', 'Ben Walker' => 'ben.walker@3squared.com', 'David Yates' => 'david.yates@3squared.com'}


	s.source       = { :git => 'https://github.com/3squared/SQKDataKit.git', :tag => "#{s.version}" }
	s.framework  = 'CoreData'
	s.requires_arc = true

	s.ios.deployment_target = '6.0'
	s.osx.deployment_target = '10.9'

	s.source_files = 'Classes/shared/SQKDataKit.h'

	s.subspec 'Core' do |ss|
		ss.source_files = ['Classes/shared/SQKDataKitErrors.{h,m}']
		ss.public_header_files = ['Classes/shared/SQKDataKitErrors.h']
	end

	s.subspec 'ContextManager' do |ss|
		ss.dependency 'SQKDataKit/Core'
		ss.source_files = ['Classes/shared/ContextManager/**/*{h,m}', 'Classes/shared/SQKDataKitErrors.h']
		ss.public_header_files = ['Classes/shared/SQKDataKitErrors.h', 'Classes/shared/ContextManager/SQKContextManager.h', 'Classes/shared/ContextManager/NSManagedObjectContext+SQKAdditions.h', 'Classes/shared/ContextManager/NSPersistentStoreCoordinator+SQKAdditions.h']
	end

	s.subspec 'ManagedObjectExtensions' do |ss|
		ss.source_files = ['Classes/shared/NSManagedObject+SQKAdditions/**/*{h,m}']
		ss.public_header_files = ['Classes/shared/NSManagedObject+SQKAdditions/NSManagedObject+SQKAdditions.h']
		ss.dependency 'SQKDataKit/Core'
	end

	s.subspec 'ManagedObjectController' do |ss|
		ss.source_files = ['Classes/shared/SQKManagedObjectController/**/*{h,m}']
		ss.public_header_files = ['Classes/shared/SQKManagedObjectController/SQKManagedObjectController.h']
		ss.dependency 'SQKDataKit/Core'
	end

	s.subspec 'FetchedTableViewController' do |ss|
		ss.platform    = :ios, '6.0'
		ss.source_files = ['Classes/ios/SQKFetchedTableViewController/**/*{h,m}']
		ss.public_header_files = ['Classes/ios/SQKFetchedTableViewController/SQKFetchedTableViewController.h']
		ss.frameworks  = 'CoreData', 'UIKit'
		ss.dependency 'SQKDataKit/Core'
	end

	s.subspec 'FetchedCollectionViewController' do |ss|
		ss.platform    = :ios, '6.0'
		ss.source_files = ['Classes/ios/SQKFetchedCollectionViewController/**/*{h,m}']
		ss.public_header_files = ['Classes/ios/SQKFetchedCollectionViewController/SQKFetchedCollectionViewController.h']
		ss.frameworks  = 'CoreData', 'UIKit'
		ss.dependency 'SQKDataKit/Core'
	end

	s.subspec 'CoreDataOperation' do |ss|
		ss.source_files = ['Classes/shared/SQKCoreDataOperation/**/*{h,m}']
		ss.public_header_files = ['Classes/shared/SQKCoreDataOperation/SQKCoreDataOperation.h']
		ss.dependency 'SQKDataKit/Core'
    ss.dependency 'SQKDataKit/ContextManager'
    ss.dependency 'SQKDataKit/ManagedObjectExtensions'
	end
end
