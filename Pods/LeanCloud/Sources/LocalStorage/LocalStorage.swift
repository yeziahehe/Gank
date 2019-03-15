//
//  LocalStorage.swift
//  LeanCloud
//
//  Created by Tianyong Tang on 2018/9/17.
//  Copyright © 2018 LeanCloud. All rights reserved.
//

import Foundation
import CoreData

/**
 Local storage.

 This type defines a local storage backed by Core Data.
 */
class LocalStorage {

    /// The application of local storage.
    let application: LCApplication

    /**
     Initialize local storage with application.

     - parameter application: The LeanCloud application.
     */
    init(application: LCApplication) {
        self.application = application
    }

    /// The global lock for all local storages.
    private static let lock = NSRecursiveLock()

    /// The lock for current local storage.
    private let lock: NSRecursiveLock = LocalStorage.lock

    /// The Storage name
    private var name: String? {
        return (self as? LocalStorageProtocol)?.name
    }

    /// The Storage type
    private var type: LocalStorageType? {
        return (self as? LocalStorageProtocol)?.type
    }

    /// This error indicates that it cannot find a file system location to store data.
    private lazy var locationNotFound = LCError(code: .notFound, reason: "Storage location not found.")

    /// The managed object context.
    private var managedObjectContext: NSManagedObjectContext?

    /**
     Load managed object context.
     */
    private func loadManagedObjectContext() throws -> NSManagedObjectContext {
        objc_sync_enter(self)

        defer { objc_sync_exit(self) }

        if let managedObjectContext = self.managedObjectContext {
            return managedObjectContext
        }

        guard let name = name else {
            throw LCError(code: .inconsistency, reason: "Unknown local storage name.")
        }

        let bundle = Bundle(for: Swift.type(of: self))

        let persistentStoreType  = try synthesizePersistentStoreType()
        let persistentController = try PersistentController(name: name, bundle: bundle, type: persistentStoreType)
        let managedObjectContext = try persistentController.createManagedObjectContext()

        self.managedObjectContext = managedObjectContext

        return managedObjectContext
    }

    /// System cache directory.
    private var systemCacheDirectory: URL? {
        do {
            return try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch let error {
            Logger.shared.error(error)
            return nil
        }
    }

    /// System application support directory.
    private var systemApplicationSupportDirectory: URL? {
        do {
            return try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch let error {
            Logger.shared.error(error)
            return nil
        }
    }

    /**
     Prepare storage file based on a system directory.

     It will create directory if needed.

     - parameter systemDirectory: The system directory.

     - returns: An URL of store file, or nil if it cannot prepare file for some reasons.
     */
    private func prepareFile(based systemDirectory: URL?) -> URL? {
        guard
            let storageName = name,
            let applicationID = application.id,
            let systemDirectory = systemDirectory
        else {
            return nil
        }

        let directory = systemDirectory
            .appendingPathComponent("LeanCloud")
            .appendingPathComponent(applicationID.md5)
            .appendingPathComponent(storageName)

        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            Logger.shared.error(error)
            return nil
        }

        let url = directory
            .appendingPathComponent(storageName)
            .appendingPathExtension("sqlite")

        return url
    }

    /**
     Prepare a file which may be cleared by OS.
     */
    private func prepareCacheFile() -> URL? {
        return prepareFile(based: systemCacheDirectory)
    }

    /**
     Prepare a file which will not be cleared by OS.
     */
    private func preparePersistentFile() -> URL? {
        return prepareFile(based: systemApplicationSupportDirectory)
    }

    /**
     Synthesize a persistent store type.
     */
    private func synthesizePersistentStoreType() throws -> PersistentStoreType {
        guard let type = type else {
            throw LCError(code: .inconsistency, reason: "Unknown local storage type.")
        }

        var persistentStoreType: PersistentStoreType

        switch type {
        case .memory:
            persistentStoreType = .memory
        case .fileCache:
            if let url = prepareCacheFile() {
                persistentStoreType = .file(url: url)
            } else {
                throw locationNotFound
            }
        case .fileCacheOrMemory:
            if let url = prepareCacheFile() {
                persistentStoreType = .file(url: url)
            } else {
                return .memory /* Fallback to memory. */
            }
        case .filePersistent:
            if let url = preparePersistentFile() {
                persistentStoreType = .file(url: url)
            } else {
                throw locationNotFound
            }
        }

        return persistentStoreType
    }

    @discardableResult
    func perform<T>(block: (NSManagedObjectContext) throws -> T) throws -> T {
        lock.lock()

        defer {
            lock.unlock()
        }

        let managedObjectContext = try loadManagedObjectContext()

        var error: Error?
        var result: T!

        managedObjectContext.performAndWait {
            do {
                result = try block(managedObjectContext)
            } catch let anError {
                error = anError
            }
        }

        if let error = error {
            throw error
        }

        return result
    }

    /**
     Create an object.
     */
    func createObject<T: NSManagedObject>() throws -> T {
        return try perform { context in
            let object = T(context: context)
            return object
        }
    }

    /**
     Create a singleton object.
     */
    func createSingleton<T: NSManagedObject>() throws -> T {
        return try perform { context in
            if let object: T = try fetchAnyObject() {
                return object
            }
            let object: T = try createObject()
            return object
        }
    }

    /**
     Create a singleton and perform task.
     */
    @discardableResult
    func withSingleton<S: NSManagedObject, T>(body: (S, NSManagedObjectContext) throws -> T) throws -> T {
        return try perform { context in
            let singleton: S = try createSingleton()
            return try body(singleton, context)
        }
    }

    /**
     Fetch only one object with optional predicate.
     */
    func fetchAnyObject<T: NSManagedObject>(predicate: NSPredicate? = nil) throws -> T? {
        return try perform { context in
            let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = predicate
            let result = try context.fetch(fetchRequest)
            return result.first
        }
    }

    /**
     Delete all objects of a given type.
     */
    func deleteAllObjects<T: NSManagedObject>(type: T.Type) throws {
        try perform { context in
            let isInMemoryStore = (context.persistentStoreCoordinator?.persistentStores.first { $0.type == NSInMemoryStoreType }) != nil

            /*
             In-memory store does not support batch delete, We have to delete one by one.
             */
            if isInMemoryStore {
                let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>

                fetchRequest.includesPropertyValues = false /* Only fetch objectID to reduce memory overhead. */

                let objects = try context.fetch(fetchRequest)

                objects.forEach { object in
                    context.delete(object)
                }
            } else {
                guard let entityName = T.entity().name else {
                    throw LCError(code: .inconsistency, reason: "Unknown entity name.")
                }

                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                try context.execute(deleteRequest)
            }
        }
    }

    /**
     Save current local storage.
     */
    func save() throws {
        try perform { context in
            try context.save()
        }
    }

}

/**
 Local storage types.
 */
enum LocalStorageType {

    /// This type indicates that data will be stored in memory.
    case memory

    /// This type indicates that data will be stored in a file, but the file may be cleared by OS.
    case fileCache

    /// Like fileCache, except that it will fallback to memory store if file cache unavailable.
    case fileCacheOrMemory

    /// This type indicates that data will be stored in a file, the file will not be cleared by OS.
    case filePersistent

}

/**
 Local storage protocol.

 Concrete local storage must confirm this protocol.
 */
protocol LocalStorageProtocol {

    /// The name of data model.
    var name: String { get }

    /// Local storage type.
    var type: LocalStorageType { get }

}
