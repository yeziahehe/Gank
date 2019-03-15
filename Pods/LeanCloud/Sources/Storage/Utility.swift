//
//  Utility.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 3/25/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

class Utility {
    static func uuid() -> String {
        let uuid = NSUUID().uuidString
        return (uuid as NSString).replacingOccurrences(of: "-", with: "").lowercased()
    }

    static func jsonString(_ object: Any) -> String {
        let data = try! JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions(rawValue: 0))
        return String(data: data, encoding: String.Encoding.utf8)!
    }

    static let mainQueue = DispatchQueue.main

    /**
     Asynchronize a task into specified dispatch queue.

     - parameter task:       The task to be asynchronized.
     - parameter queue:      The dispatch queue into which the task will be enqueued.
     - parameter completion: The completion closure to be called on main thread after task executed.
     */
    static func asynchronize<Result>(_ task: @escaping () -> Result, _ queue: DispatchQueue, _ completion: @escaping (Result) -> Void) {
        queue.async {
            let result = task()
            mainQueue.async {
                completion(result)
            }
        }
    }
}
