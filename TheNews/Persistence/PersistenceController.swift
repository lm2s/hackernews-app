//
//  PersistenceController.swift
//  TheNews
//
//  Created by Luís Silva on 02/12/2020.
//

import CoreData

class PersistenceController {
    private(set) var persistentContainer: NSPersistentContainer!

    let inMemory: Bool
    var viewContext: NSManagedObjectContext { return persistentContainer.viewContext }

    init(inMemory: Bool = false) {
        self.inMemory = inMemory

        CommentsValueTransformer.register()

        let (container, isSetup) = loadContainer()
        if !isSetup {
            destroy(container: container)

            let (newContainer, isSetup) = loadContainer()
            if !isSetup {
                fatalError()
            } else {
                self.persistentContainer = newContainer
            }
        }
        else {
            self.persistentContainer = container
        }
    }

    // MARK: - Core Data Saving support

    func saveContext () {
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
    }

    private func loadContainer() -> (NSPersistentContainer, Bool) {
        let container = NSPersistentContainer(name: "TheNews")

        let storeDescription = NSPersistentStoreDescription()
        storeDescription.shouldAddStoreAsynchronously = false
        storeDescription.type = inMemory ? NSInMemoryStoreType : NSSQLiteStoreType
        storeDescription.url = storeURL

        container.persistentStoreDescriptions = [storeDescription]

        var isSetup: Bool = false

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            isSetup = error == nil
        })

        return (container, isSetup)
    }

    private func destroy(container: NSPersistentContainer) {
        _ = try? FileManager.default.removeItem(at: storeURL)
    }

    var storeURL: URL {
        return NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("store.db")
    }
}
