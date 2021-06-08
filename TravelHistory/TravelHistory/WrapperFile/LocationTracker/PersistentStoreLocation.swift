//
//  PersistentStoreLocation.swift
//
//  Created by SAHIL PASHA on 07/06/21.
//

import UIKit
import CoreData
import CoreLocation

class PersistentStoreLocation: NSObject {
    
    var viewContext: NSManagedObjectContext {
        if #available(iOS 10.0, *) {
            return self.persistentContainer.viewContext
        }
        
        return self.managedObjectContextIs
        
    }
    
    
    
    //******************************************************************//
    //****************************** iOS 9 ****************************//
    //*****************************************************************//
    // iOS 9 and below
    private lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        if let modelURL = Bundle.main.url(forResource: "PresistentStoreLocation", withExtension: "momd"),
           let manageObjectModel = NSManagedObjectModel(contentsOf: modelURL) {
            return manageObjectModel
        }
        
        fatalError("It is a fatal error for the application not to be able to find and load its model error")
        
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    private lazy var managedObjectContextIs: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    
    //******************************************************
    //*********************** iOS 10 ***********************
    //******************************************************
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "TravelHistory")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
            
        } else {
            
            if self.viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
        
    }
    
    func removeAllLocations() {
        let managedObjectContext = self.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try managedObjectContext.execute(request)
            self.saveContext()
        } catch {
            print(error)
        }
        
    }
    
    func removeObjects(list: [NSManagedObject]) {
        let managedObjectContext = self.viewContext
        for obj in list {
            managedObjectContext.delete(obj)
        }
        self.saveContext()
    }
    
    func save(location: CLLocation) {
        
        let managedObjectContext = self.viewContext
        guard let locationObject = NSEntityDescription.insertNewObject(forEntityName: "Location", into: managedObjectContext ) as? Location else {
            return
        }
        
        locationObject.latitude = location.coordinate.latitude
        locationObject.longitude = location.coordinate.longitude
        locationObject.timestamp = Date()
        locationObject.location = location
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
        
    }
    
    func getLastLocation() -> CLLocation? {
        let managedObjectContext = self.viewContext
        let locationRequest = NSFetchRequest<Location>(entityName: "Location")
        let sorting = NSSortDescriptor(key: "timestamp", ascending: false)
        locationRequest.sortDescriptors = [sorting]
        locationRequest.fetchLimit = 1
        do {
            let fetchedLocations = try managedObjectContext.fetch(locationRequest)
            let locationObj = fetchedLocations.last
            if let location = locationObj?.location as? CLLocation {
                return location
            }
            return nil
        } catch {
            return nil
        }
    }
    
    func getLocations() -> [CLLocation] {
        
        let managedObjectContext = self.viewContext
        let locationRequest = NSFetchRequest<Location>(entityName: "Location")
        let sorting = NSSortDescriptor(key: "timestamp", ascending: false)
        locationRequest.sortDescriptors = [sorting]
        
        do {
            let fetchedLocations = try managedObjectContext.fetch(locationRequest)
            let locations = fetchedLocations.map({ (locationObj: Location) -> CLLocation in
                if let location = locationObj.location as? CLLocation {
                  return location
                }
                
                fatalError("---- Location object not found.")
            })
            return locations
        } catch {
            return [CLLocation]()
        }
        
    }
    
    func getSavedLocations(limit: Int, ascending: Bool) -> [Location] {
        
        let managedObjectContext = self.viewContext
        let locationRequest = NSFetchRequest<Location>(entityName: "Location")
        
        if limit > 0 {
            locationRequest.fetchLimit = limit
        }
        
        let sorting = NSSortDescriptor(key: "timestamp", ascending: true)
        locationRequest.sortDescriptors = [sorting]
        
        do {
            let fetchedLocations = try managedObjectContext.fetch(locationRequest)
            return fetchedLocations
        } catch {
            return [Location]()
        }
        
    }
    
}
