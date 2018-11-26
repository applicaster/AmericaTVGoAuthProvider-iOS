//
//  AmericaTVGoUtils.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/26/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import Foundation

class AmericaTVGoUtils {
    class func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
