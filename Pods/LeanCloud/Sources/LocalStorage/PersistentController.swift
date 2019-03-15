//
//  PersistentController.swift
//  LeanCloud
//
//  Created by Tianyong Tang on 2018/9/17.
//  Copyright © 2018 LeanCloud. All rights reserved.
//

import Foundation
import CoreData

enum PersistentStoreType {

    case memory

    case file(url: URL)

}

class PersistentController {

    let name: String

    let bundle: Bundle

    let managedObjectModel: NSManagedObjectModel

    let type: PersistentStoreType

    /**
     Initialize persistent manager.

     - parameter name: The name of the NSPersistentContainer object.
     - parameter storeType: The store type.
     */
    init(name: String, bundle: Bundle, type: PersistentStoreType) throws {
        guard let momdFile = bundle.url(forResource: name, withExtension: "momd") else {
            throw LCError(code: .inconsistency, reason: "Failed to locate momd file.")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: momdFile) else {
            throw LCError(code: .inconsistency, reason: "Failed to create object model from momd file.")
        }

        self.name = name
        self.bundle = bundle
        self.managedObjectModel = managedObjectModel
        self.type = type
    }

    /**
     Create managed object context.
     */
    func createManagedObjectContext() throws -> NSManagedObjectContext {
        let options = [
            NSInferMappingModelAutomaticallyOption: true,
            NSMigratePersistentStoresAutomaticallyOption: true
        ]

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        switch type {
        case .memory:
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: options)
        case .file(let url):
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        }

        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        managedObjectContext.retainsRegisteredObjects = true

        return managedObjectContext
    }

}
