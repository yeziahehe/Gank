//
//  Request.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 3/30/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation
import Alamofire

/**
 This type represents HTTP request.
 */
public class LCRequest: NSObject {

    /**
     Request states.
     */
    enum State {

        case resumed

        case suspended

        case cancelled

    }

    var state: State = .resumed

    private let lock = NSRecursiveLock()

    /* Override initializer to make it internal. */
    override init() {
        /* Nop */
    }

    func perform(body: () -> Void) {
        lock.lock()

        defer {
            lock.unlock()
        }

        body()
    }

    func setNewState(_ newState: State, beforeChange: () -> Void) {
        perform {
            switch state {
            case .resumed:
                if newState == .suspended || newState == .cancelled {
                    beforeChange()
                    state = newState
                }
            case .suspended:
                if newState == .resumed || newState == .cancelled {
                    beforeChange()
                    state = newState
                }
            case .cancelled:
                break
            }
        }
    }

    public func resume() {
        /* Nop */
    }

    public func suspend() {
        /* Nop */
    }

    public func cancel() {
        /* Nop */
    }

}

/**
 This type represents a single HTTP request.
 */
class LCSingleRequest: LCRequest {

    let request: Request?

    init(request: Request?) {
        self.request = request
    }

    override func resume() {
        setNewState(.resumed) {
            request?.resume()
        }
    }

    override func suspend() {
        setNewState(.suspended) {
            request?.suspend()
        }
    }

    override func cancel() {
        setNewState(.cancelled) {
            request?.cancel()
        }
    }

}

/**
 This type represents a sequence of HTTP requests.
 */
class LCSequenceRequest: LCRequest {

    private(set) var request: LCRequest?

    func setCurrentRequest(_ request: LCRequest) {
        perform {
            self.request = request

            switch state {
            case .resumed:
                request.resume()
            case .suspended:
                request.suspend()
            case .cancelled:
                request.cancel()
            }
        }
    }

    func setCurrentRequest(_ request: Request) {
        let request = LCSingleRequest(request: request)

        setCurrentRequest(request)
    }

    override func resume() {
        setNewState(.resumed) {
            request?.resume()
        }
    }

    override func suspend() {
        setNewState(.suspended) {
            request?.suspend()
        }
    }

    override func cancel() {
        setNewState(.cancelled) {
            request?.cancel()
        }
    }

}
