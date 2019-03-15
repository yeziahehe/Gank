//
//  Installation.swift
//  LeanCloud
//
//  Created by Tianyong Tang on 2018/10/12.
//  Copyright © 2018 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud installation type.
 */
public final class LCInstallation: LCObject {

    /// The badge of installation.
    @objc public dynamic var badge: LCNumber?

    /// The time zone of installtion.
    @objc public dynamic var timeZone: LCString?

    /// The channels of installation, which contains client ID of IM.
    @objc public dynamic var channels: LCArray?

    /// The type of device.
    @objc public dynamic var deviceType: LCString?

    /// The device token used to push notification.
    @objc public private(set) dynamic var deviceToken: LCString?

    /// The device profile. You can use this property to select one from mutiple push certificates or configurations.
    @objc public private(set) dynamic var deviceProfile: LCString?

    /// The installation ID of device, it's mainly for Android device.
    @objc public dynamic var installationId: LCString?

    /// The APNs topic of installation.
    @objc public dynamic var apnsTopic: LCString?

    /// The APNs Team ID of installation.
    @objc public private(set) dynamic var apnsTeamId: LCString?

    public override class func objectClassName() -> String {
        return "_Installation"
    }

    public required init() {
        super.init()

        initialize()
    }

    func initialize() {
        timeZone = NSTimeZone.system.identifier.lcString

        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            apnsTopic = bundleIdentifier.lcString
        }

        #if os(iOS)
        deviceType = "ios"
        #elseif os(macOS)
        deviceType = "macos"
        #elseif os(watchOS)
        deviceType = "watchos"
        #elseif os(tvOS)
        deviceType = "tvos"
        #elseif os(Linux)
        deviceType = "linux"
        #elseif os(FreeBSD)
        deviceType = "freebsd"
        #elseif os(Android)
        deviceType = "android"
        #elseif os(PS4)
        deviceType = "ps4"
        #elseif os(Windows)
        deviceType = "windows"
        #elseif os(Cygwin)
        deviceType = "cygwin"
        #elseif os(Haiku)
        deviceType = "haiku"
        #endif
    }

    /**
     Set required properties for installation.

     - parameter deviceToken: The device token.
     - parameter deviceProfile: The device profile.
     - parameter apnsTeamId: The Team ID of your Apple Developer Account.
     */
    public func set(
        deviceToken: LCDeviceTokenConvertible,
        deviceProfile: LCStringConvertible? = nil,
        apnsTeamId: LCStringConvertible)
    {
        self.deviceToken = deviceToken.lcDeviceToken

        if let deviceProfile = deviceProfile {
            self.deviceProfile = deviceProfile.lcString
        }

        self.apnsTeamId = apnsTeamId.lcString
    }

    override func preferredBatchRequest(method: HTTPClient.Method, path: String, internalId: String) throws -> [String : Any]? {
        switch method {
        case .post, .put:
            var request: [String: Any] = [:]

            request["method"] = HTTPClient.Method.post.rawValue
            request["path"] = try HTTPClient.default.getBatchRequestPath(object: self, method: .post)

            if var body = dictionary.lconValue as? [String: Any] {
                body["__internalId"] = internalId

                body.removeValue(forKey: "createdAt")
                body.removeValue(forKey: "updatedAt")

                request["body"] = body
            }

            return request
        default:
            return nil
        }
    }

    override func validateBeforeSaving() throws {
        try super.validateBeforeSaving()

        guard let _ = deviceToken else {
            throw LCError(code: .inconsistency, reason: "Installation device token not found.")
        }
        guard let _ = apnsTeamId else {
            throw LCError(code: .inconsistency, reason: "Installation APNs team ID not found.")
        }
    }

    override func objectDidSave() {
        super.objectDidSave()

        let application = LCApplication.default

        if application.currentInstallation == self {
            application.storageContextCache.installation = self
        }
    }

}

extension LCApplication {

    public var currentInstallation: LCInstallation {
        return lc_lazyload("currentInstallation", .OBJC_ASSOCIATION_RETAIN) {
            storageContextCache.installation ?? LCInstallation()
        }
    }

}


public protocol LCDeviceTokenConvertible {

    var lcDeviceToken: LCString { get }

}

extension String: LCDeviceTokenConvertible {

    public var lcDeviceToken: LCString {
        return lcString
    }

}

extension NSString: LCDeviceTokenConvertible {

    public var lcDeviceToken: LCString {
        return (self as String).lcDeviceToken
    }

}

extension Data: LCDeviceTokenConvertible {

    public var lcDeviceToken: LCString {
        let string = map { String(format: "%02.2hhx", $0) }.joined()

        return LCString(string)
    }

}

extension NSData: LCDeviceTokenConvertible {

    public var lcDeviceToken: LCString {
        return (self as Data).lcDeviceToken
    }

}
