//
//  StorageContextCache.swift
//  LeanCloud
//
//  Created by Tianyong Tang on 2018/10/17.
//  Copyright © 2018 LeanCloud. All rights reserved.
//

import Foundation
import CoreData

/**
 Storage context cache.
 */
final class StorageContextCache: LocalStorage, LocalStorageProtocol {

    let name = "StorageContext"

    var type = LocalStorageType.fileCacheOrMemory

    /**
     Current installation.
     */
    var installation: LCInstallation? {
        get {
            do {
                return try withSingleton { (storageContext: StorageContext, context) in
                    guard let data = storageContext.installation else {
                        return nil
                    }

                    let installation = NSKeyedUnarchiver.unarchiveObject(with: data) as? LCInstallation

                    return installation
                }
            } catch {
                return nil
            }
        }
        set {
            do {
                try withSingleton { (storageContext: StorageContext, context) in
                    var data: Data?

                    if let installation = newValue {
                        data = NSKeyedArchiver.archivedData(withRootObject: installation)
                    }

                    storageContext.installation = data

                    try context.save()
                }
            } catch {
                /* Nop */
            }
        }
    }

}
