//
//  LCUser.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 5/7/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import Foundation

/**
 LeanCloud user type.

 A base type of LeanCloud built-in user system.
 You can extend this class with custom properties.
 However, LCUser can be extended only once.
 */
open class LCUser: LCObject {
    /// Username of user.
    @objc open dynamic var username: LCString?

    /**
     Password of user.

     - note: this property will not be filled in when fetched or logged in for security.
     */
    @objc open dynamic var password: LCString?

    /**
     Email of user.

     If the "Enable Email Verification" application option is enabled,
     a verification email will be sent to user when user registered with an email address.
     */
    @objc open dynamic var email: LCString?

    /// A flag indicates whether email is verified or not.
    @objc open private(set) dynamic var emailVerified: LCBool?

    /**
     Mobile phone number.

     If the "Enable Mobile Phone Number Verification" application option is enabled,
     an sms message will be sent to user's phone when user registered with a phone number.
     */
    @objc open dynamic var mobilePhoneNumber: LCString?

    /// A flag indicates whether mobile phone is verified or not.
    @objc open private(set) dynamic var mobilePhoneVerified: LCBool?

    /// Session token of user authenticated by server.
    @objc open private(set) dynamic var sessionToken: LCString?

    /// Current authenticated user.
    public static var current: LCUser? = nil

    public final override class func objectClassName() -> String {
        return "_User"
    }

    /**
     Sign up an user.

     - returns: The result of signing up request.
     */
    open func signUp() -> LCBooleanResult {
        return expect { fulfill in
            self.signUp(completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Sign up an user asynchronously.

     - parameter completion: The completion callback closure.
     */
    open func signUp(_ completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return signUp(completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    open func signUp(completionInBackground completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return type(of: self).save([self], completionInBackground: completion)
    }

    // MARK: Log in with username and password

    /**
     Log in with username and password.
     
     - parameter username: The username.
     - parameter password: The password.

     - returns: The result of login request.
     */
    public static func logIn<User: LCUser>(username: String, password: String) -> LCValueResult<User> {
        return expect { fulfill in
            logIn(username: username, password: password, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Log in with username and password asynchronously.

     - parameter username:   The username.
     - parameter password:   The password.
     - parameter completion: The completion callback closure.
     */
    public static func logIn<User: LCUser>(username: String, password: String, completion: @escaping (LCValueResult<User>) -> Void) -> LCRequest {
        return logIn(username: username, password: password, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func logIn<User: LCUser>(username: String, password: String, completionInBackground completion: @escaping (LCValueResult<User>) -> Void) -> LCRequest {
        let parameters = [
            "username": username,
            "password": password
        ]

        let request = logIn(parameters: parameters, completionInBackground: completion)

        return request
    }

    // MARK: Log in with phone number and password

    /**
     Log in with mobile phone number and password.

     - parameter username: The mobile phone number.
     - parameter password: The password.

     - returns: The result of login request.
     */
    public static func logIn<User: LCUser>(mobilePhoneNumber: String, password: String) -> LCValueResult<User> {
        return expect { fulfill in
            logIn(mobilePhoneNumber: mobilePhoneNumber, password: password, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Log in with mobile phone number and password asynchronously.

     - parameter mobilePhoneNumber: The mobile phone number.
     - parameter password:          The password.
     - parameter completion:        The completion callback closure.
     */
    public static func logIn<User: LCUser>(mobilePhoneNumber: String, password: String, completion: @escaping (LCValueResult<User>) -> Void) -> LCRequest {
        return logIn(mobilePhoneNumber: mobilePhoneNumber, password: password, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func logIn<User: LCUser>(mobilePhoneNumber: String, password: String, completionInBackground completion: @escaping (LCValueResult<User>) -> Void) -> LCRequest {
        let parameters = [
            "password": password,
            "mobilePhoneNumber": mobilePhoneNumber
        ]

        let request = logIn(parameters: parameters, completionInBackground: completion)

        return request
    }

    // MARK: Log in with phone number and verification code

    /**
     Log in with mobile phone number and verification code.

     - parameter mobilePhoneNumber: The mobile phone number.
     - parameter verificationCode:  The verification code.

     - returns: The result of login request.
     */
    public static func logIn<User: LCUser>(mobilePhoneNumber: String, verificationCode: String) -> LCValueResult<User> {
        return expect { fulfill in
            logIn(mobilePhoneNumber: mobilePhoneNumber, verificationCode: verificationCode, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Log in with mobile phone number and verification code asynchronously.

     - parameter mobilePhoneNumber: The mobile phone number.
     - parameter verificationCode:  The verification code.
     - parameter completion:        The completion callback closure.
     */
    public static func logIn<User: LCUser>(mobilePhoneNumber: String, verificationCode: String, completion: @escaping (LCValueResult<User>) -> Void) -> LCRequest {
        return logIn(mobilePhoneNumber: mobilePhoneNumber, verificationCode: verificationCode, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func logIn<User: LCUser>(mobilePhoneNumber: String, verificationCode: String, completionInBackground completion: @escaping (LCValueResult<User>) -> Void) -> LCRequest {
        let parameters = [
            "smsCode": verificationCode,
            "mobilePhoneNumber": mobilePhoneNumber
        ]

        let request = logIn(parameters: parameters, completionInBackground: completion)

        return request
    }

    // MARK: Log in with parameters

    /**
     Log in with parameters asynchronously.

     - parameter parameters: The login parameters.
     - parameter completion: The completion callback, it will be called in background thread.

     - returns: A login request.
     */
    @discardableResult
    private static func logIn<User: LCUser>(parameters: [String: Any], completionInBackground completion: @escaping (LCValueResult<User>) -> Void) -> LCRequest {
        let request = HTTPClient.default.request(.post, "login", parameters: parameters) { response in
            let result = LCValueResult<User>(response: response)

            switch result {
            case .success(let user):
                LCUser.current = user
            case .failure:
                break
            }

            completion(result)
        }

        return request
    }

    // MARK: Log in with session token

    /**
     Log in with session token.

     - parameter sessionToken: The session token.

     - returns: The result of login request.
     */
    public static func logIn<User: LCUser>(sessionToken: String) -> LCValueResult<User> {
        return expect { fulfill in
            logIn(sessionToken: sessionToken, completionInBackground: { (result: LCValueResult<User>) in
                fulfill(result)
            })
        }
    }

    /**
     Log in with session token asynchronously.

     - parameter sessionToken: The session token.
     - parameter completion:   The completion callback closure, it will be called in main thread.
     */
    public static func logIn<User: LCUser>(sessionToken: String, completion: @escaping (LCValueResult<User>) -> Void) -> LCRequest {
        return logIn(sessionToken: sessionToken, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    /**
     Log in with session token asynchronously.

     - parameter sessionToken: The session token.
     - parameter completion:   The completion callback closure, it will be called in a background thread.
     */
    @discardableResult
    private static func logIn<User: LCUser>(sessionToken: String, completionInBackground completion: @escaping (LCValueResult<User>) -> Void) -> LCRequest {
        let className = objectClassName()
        let classEndpoint = HTTPClient.default.getClassEndpoint(className: className)

        let endpoint = "\(classEndpoint)/me"
        let parameters = ["session_token": sessionToken]

        let request = HTTPClient.default.request(.get, endpoint, parameters: parameters) { response in
            let result = LCValueResult<User>(response: response)

            switch result {
            case .success(let user):
                LCUser.current = user
            case .failure:
                break
            }

            completion(result)
        }

        return request
    }

    // MARK: Sign up or log in with phone number and verification code

    /**
     Sign up or log in with mobile phone number and verification code.

     This method will sign up a user automatically if user for mobile phone number not found.

     - parameter mobilePhoneNumber: The mobile phone number.
     - parameter verificationCode:  The verification code.
     */
    public static func signUpOrLogIn<User: LCUser>(mobilePhoneNumber: String, verificationCode: String) -> LCValueResult<User> {
        return expect { fulfill in
            signUpOrLogIn(mobilePhoneNumber: mobilePhoneNumber, verificationCode: verificationCode, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Sign up or log in with mobile phone number and verification code asynchronously.

     - parameter mobilePhoneNumber: The mobile phone number.
     - parameter verificationCode:  The verification code.
     - parameter completion:        The completion callback closure.
     */
    public static func signUpOrLogIn<User: LCUser>(mobilePhoneNumber: String, verificationCode: String, completion: @escaping (LCValueResult<User>) -> Void) -> LCRequest {
        return signUpOrLogIn(mobilePhoneNumber: mobilePhoneNumber, verificationCode: verificationCode, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func signUpOrLogIn<User: LCUser>(mobilePhoneNumber: String, verificationCode: String, completionInBackground completion: @escaping (LCValueResult<User>) -> Void) -> LCRequest {
        let parameters = [
            "smsCode": verificationCode,
            "mobilePhoneNumber": mobilePhoneNumber
        ]

        let request = HTTPClient.default.request(.post, "usersByMobilePhone", parameters: parameters) { response in
            let result = LCValueResult<User>(response: response)

            switch result {
            case .success(let user):
                LCUser.current = user
            case .failure:
                break
            }

            completion(result)
        }

        return request
    }

    /**
     Log out current user.
     */
    public static func logOut() {
        current = nil
    }

    // MARK: Send verification mail

    /**
     Request to send a verification mail to specified email address.

     - parameter email: The email address to where the mail will be sent.

     - returns: The result of verification request.
     */
    public static func requestVerificationMail(email: String) -> LCBooleanResult {
        return expect { fulfill in
            requestVerificationMail(email: email, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Request to send a verification mail to specified email address asynchronously.

     - parameter email:      The email address to where the mail will be sent.
     - parameter completion: The completion callback closure.
     */
    public static func requestVerificationMail(email: String, completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return requestVerificationMail(email: email, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func requestVerificationMail(email: String, completionInBackground completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        let parameters = ["email": email]
        let request = HTTPClient.default.request(.post, "requestEmailVerify", parameters: parameters) { response in
            completion(LCBooleanResult(response: response))
        }
        return request
    }

    // MARK: Send verification code

    /**
     Request to send a verification code to specified mobile phone number.

     - parameter mobilePhoneNumber: The mobile phone number where the verification code will be sent to.

     - returns: The result of request.
     */
    public static func requestVerificationCode(mobilePhoneNumber: String) -> LCBooleanResult {
        return expect { fulfill in
            requestVerificationCode(mobilePhoneNumber: mobilePhoneNumber, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Request to send a verification code to specified mobile phone number asynchronously.

     - parameter mobilePhoneNumber: The mobile phone number where the verification code will be sent to.
     - parameter completion:        The completion callback closure.
     */
    public static func requestVerificationCode(mobilePhoneNumber: String, completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return requestVerificationCode(mobilePhoneNumber: mobilePhoneNumber, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func requestVerificationCode(mobilePhoneNumber: String, completionInBackground completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        let parameters = ["mobilePhoneNumber": mobilePhoneNumber]
        let request = HTTPClient.default.request(.post, "requestMobilePhoneVerify", parameters: parameters) { response in
            completion(LCBooleanResult(response: response))
        }
        return request
    }

    // MARK: Verify phone number

    /**
     Verify a mobile phone number.

     - parameter mobilePhoneNumber: The mobile phone number.
     - parameter verificationCode:  The verification code.

     - returns: The result of verification request.
     */
    public static func verifyMobilePhoneNumber(_ mobilePhoneNumber: String, verificationCode: String) -> LCBooleanResult {
        return expect { fulfill in
            verifyMobilePhoneNumber(mobilePhoneNumber, verificationCode: verificationCode, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Verify mobile phone number with code asynchronously.

     - parameter mobilePhoneNumber: The mobile phone number.
     - parameter verificationCode:  The verification code.
     - parameter completion:        The completion callback closure.
     */
    public static func verifyMobilePhoneNumber(_ mobilePhoneNumber: String, verificationCode: String, completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return verifyMobilePhoneNumber(mobilePhoneNumber, verificationCode: verificationCode, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func verifyMobilePhoneNumber(_ mobilePhoneNumber: String, verificationCode: String, completionInBackground completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        let parameters = ["mobilePhoneNumber": mobilePhoneNumber]
        let request = HTTPClient.default.request(.get, "verifyMobilePhone/\(verificationCode)", parameters: parameters) { response in
            completion(LCBooleanResult(response: response))
        }
        return request
    }

    // MARK: Send a login verification code

    /**
     Request a verification code for login with mobile phone number.

     - parameter mobilePhoneNumber: The mobile phone number where the verification code will be sent to.

     - returns: The result of request.
     */
    public static func requestLoginVerificationCode(mobilePhoneNumber: String) -> LCBooleanResult {
        return expect { fulfill in
            requestLoginVerificationCode(mobilePhoneNumber: mobilePhoneNumber, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Request a verification code for login with mobile phone number asynchronously.

     - parameter mobilePhoneNumber: The mobile phone number where the verification code message will be sent to.
     - parameter completion:        The completion callback closure.
     */
    public static func requestLoginVerificationCode(mobilePhoneNumber: String, completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return requestLoginVerificationCode(mobilePhoneNumber: mobilePhoneNumber, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func requestLoginVerificationCode(mobilePhoneNumber: String, completionInBackground completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        let parameters = ["mobilePhoneNumber": mobilePhoneNumber]
        let request = HTTPClient.default.request(.post, "requestLoginSmsCode", parameters: parameters) { response in
            completion(LCBooleanResult(response: response))
        }

        return request
    }

    // MARK: Send password reset mail

    /**
     Request password reset mail.

     - parameter email: The email address where the password reset mail will be sent to.

     - returns: The result of request.
     */
    public static func requestPasswordReset(email: String) -> LCBooleanResult {
        return expect { fulfill in
            requestPasswordReset(email: email, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Request password reset email asynchronously.

     - parameter email:      The email address where the password reset email will be sent to.
     - parameter completion: The completion callback closure.
     */
    public static func requestPasswordReset(email: String, completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return requestPasswordReset(email: email, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func requestPasswordReset(email: String, completionInBackground completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        let parameters = ["email": email]
        let request = HTTPClient.default.request(.post, "requestPasswordReset", parameters: parameters) { response in
            completion(LCBooleanResult(response: response))
        }

        return request
    }

    // MARK: Send password reset short message

    /**
     Request password reset verification code.

     - parameter mobilePhoneNumber: The mobile phone number where the password reset verification code will be sent to.

     - returns: The result of request.
     */
    public static func requestPasswordReset(mobilePhoneNumber: String) -> LCBooleanResult {
        return expect { fulfill in
            requestPasswordReset(mobilePhoneNumber: mobilePhoneNumber, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Request password reset verification code asynchronously.

     - parameter mobilePhoneNumber: The mobile phone number where the password reset verification code will be sent to.
     - parameter completion:        The completion callback closure.
     */
    public static func requestPasswordReset(mobilePhoneNumber: String, completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return requestPasswordReset(mobilePhoneNumber: mobilePhoneNumber, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func requestPasswordReset(mobilePhoneNumber: String, completionInBackground completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        let parameters = ["mobilePhoneNumber": mobilePhoneNumber]
        let request = HTTPClient.default.request(.post, "requestPasswordResetBySmsCode", parameters: parameters) { response in
            completion(LCBooleanResult(response: response))
        }

        return request
    }

    // MARK: Reset password with verification code and new password

    /**
     Reset password with verification code and new password.

     - note: 
     This method will reset password of `LCUser.current`.
     If `LCUser.current` is nil, in other words, no user logged in,
     password reset will be failed because of permission.

     - parameter mobilePhoneNumber: The mobile phone number of user.
     - parameter verificationCode:  The verification code in password reset message.
     - parameter newPassword:       The new password.

     - returns: The result of reset request.
     */
    public static func resetPassword(mobilePhoneNumber: String, verificationCode: String, newPassword: String) -> LCBooleanResult {
        return expect { fulfill in
            resetPassword(mobilePhoneNumber: mobilePhoneNumber, verificationCode: verificationCode, newPassword: newPassword, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Reset password with verification code and new password asynchronously.

     - parameter mobilePhoneNumber: The mobile phone number of user.
     - parameter verificationCode:  The verification code in password reset message.
     - parameter newPassword:       The new password.
     - parameter completion:        The completion callback closure.
     */
    public static func resetPassword(mobilePhoneNumber: String, verificationCode: String, newPassword: String, completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return resetPassword(mobilePhoneNumber: mobilePhoneNumber, verificationCode: verificationCode, newPassword: newPassword, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private static func resetPassword(mobilePhoneNumber: String, verificationCode: String, newPassword: String, completionInBackground completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        let parameters = [
            "password": newPassword,
            "mobilePhoneNumber": mobilePhoneNumber
        ]
        let request = HTTPClient.default.request(.put, "resetPasswordBySmsCode/\(verificationCode)", parameters: parameters) { response in
            completion(LCBooleanResult(response: response))
        }

        return request
    }

    // MARK: Update password with new password

    /**
     Update password for user.

     - parameter oldPassword: The old password.
     - parameter newPassword: The new password.

     - returns: The result of update request.
     */
    open func updatePassword(oldPassword: String, newPassword: String) -> LCBooleanResult {
        return expect { fulfill in
            self.updatePassword(oldPassword: oldPassword, newPassword: newPassword, completionInBackground: { result in
                fulfill(result)
            })
        }
    }

    /**
     Update password for user asynchronously.

     - parameter oldPassword: The old password.
     - parameter newPassword: The new password.
     - parameter completion:  The completion callback closure.
     */
    open func updatePassword(oldPassword: String, newPassword: String, completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        return updatePassword(oldPassword: oldPassword, newPassword: newPassword, completionInBackground: { result in
            mainQueueAsync {
                completion(result)
            }
        })
    }

    @discardableResult
    private func updatePassword(oldPassword: String, newPassword: String, completionInBackground completion: @escaping (LCBooleanResult) -> Void) -> LCRequest {
        guard let endpoint = HTTPClient.default.getObjectEndpoint(object: self) else {
            return HTTPClient.default.request(
                error: LCError(code: .notFound, reason: "User not found."),
                completionHandler: completion)
        }
        guard let sessionToken = sessionToken else {
            return HTTPClient.default.request(
                error: LCError(code: .notFound, reason: "Session token not found."),
                completionHandler: completion)
        }

        let parameters = [
            "old_password": oldPassword,
            "new_password": newPassword
        ]
        let headers = [HTTPClient.HeaderFieldName.session: sessionToken.value]

        let request = HTTPClient.default.request(.put, "\(endpoint)/updatePassword", parameters: parameters, headers: headers) { response in
            if let error = LCError(response: response) {
                completion(.failure(error: error))
            } else {
                if let dictionary = response.value as? [String: Any] {
                    ObjectProfiler.shared.updateObject(self, dictionary)
                }
                completion(.success)
            }
        }

        return request
    }
}
