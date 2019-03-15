//
//  AppRouterCache.swift
//  LeanCloud
//
//  Created by Tianyong Tang on 2018/9/17.
//  Copyright © 2018 LeanCloud. All rights reserved.
//

import Foundation

/**
 App router cache.
 */
final class AppRouterCache: LocalStorage, LocalStorageProtocol {

    let name = "AppRouterCache"

    var type = LocalStorageType.fileCacheOrMemory

    /**
     Cache a host table with expiration date.

     - parameter hostTable: The host table indexed by API module.
     - parameter expirationDate: The date that host table will expires.
     */
    func cacheHostTable(_ hostTable: [HTTPRouter.Module: String], expirationDate: Date) throws {
        try perform { context in
            try deleteAllObjects(type: AppRouterTable.self)

            let appRouterTable: AppRouterTable = try createSingleton()

            appRouterTable.expirationDate = expirationDate

            hostTable.forEach { (module, host) in
                let appRouterRecord = AppRouterRecord(context: context)

                appRouterRecord.key = module.key
                appRouterRecord.value = host

                appRouterRecord.table = appRouterTable
            }

            try save()
        }
    }

    /**
     Fetch host for given module.

     - parameter module: The API module.

     - returns: The host for given API module, or nil if expired.
     */
    func fetchHost(module: HTTPRouter.Module) throws -> String? {
        return try perform { context in
            guard let appRouterTable: AppRouterTable = try fetchAnyObject() else {
                return nil
            }

            /* If router table expires, clear cache. */
            guard let expirationDate = appRouterTable.expirationDate, Date() < expirationDate else {
                try deleteAllObjects(type: AppRouterTable.self)
                try save()
                return nil
            }

            let predicate = NSPredicate(format: "table = %@ and key = %@", argumentArray: [appRouterTable, module.key])

            guard let appRouterRecord: AppRouterRecord = try fetchAnyObject(predicate: predicate) else {
                return nil
            }

            let host = appRouterRecord.value

            return host
        }
    }

}
