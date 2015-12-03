//
//  CoreDataManager.swift
//  My Movies
//
//  Created by Madalin Sava on 03/12/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation
import CoreData

protocol NamedManagedObject {
	static var entityName: String {get}
}

class CoreDataManager {
	static let instance = CoreDataManager()
	
	var storeType: String = NSSQLiteStoreType
	
	func save() -> Bool {
		do {
			try managedObjectContext.save()
		} catch let error as NSError {
			print("Core Data save error - " + error.localizedDescription)
			return false
		}
		
		return true
	}
	
	func getObjects<T where T: NSManagedObject, T: NamedManagedObject>(ofType type: T.Type, withPredicate predicate: NSPredicate? = nil) -> [T]? {
		
		let fetchRequest = NSFetchRequest(entityName: type.entityName)
		if predicate != nil {
			fetchRequest.predicate = predicate
		}
		
		do {
			return try managedObjectContext.executeFetchRequest(fetchRequest) as? [T]
		} catch let error as NSError {
			print(error.localizedDescription)
		}
		
		return nil
	}
	
	func createEntity<T where T: NSManagedObject, T: NamedManagedObject>(ofType type: T.Type) -> T {
		
		let entityDescription = NSEntityDescription.entityForName(T.entityName, inManagedObjectContext: managedObjectContext)!
		let entity = T(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
		return entity
	}
	
	private lazy var applicationDocumentsDirectory: NSURL = {
		// The directory the application uses to store the Core Data store file. This code uses a directory named "ms.CoreDataTest" in the application's documents Application Support directory.
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[0]
	}()
	
	private lazy var managedObjectModel: NSManagedObjectModel = {
		// The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
		let modelURL = NSBundle.mainBundle().URLForResource("Movies", withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()
	
	private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		// The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
		// Create the coordinator and store
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		var url: NSURL?
		if self.storeType == NSSQLiteStoreType {
			url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
		}
		var failureReason = "There was an error creating or loading the application's saved data."
		do {
			try coordinator.addPersistentStoreWithType(self.storeType, configuration: nil, URL: url, options: nil)
		} catch {
			// Report any error we got.
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSLocalizedFailureReasonErrorKey] = failureReason
			
			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			// Replace this with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		}
		
		return coordinator
	}()
	
	private lazy var managedObjectContext: NSManagedObjectContext = {
		// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()
}
