//
//  Constants.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 13/03/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit

enum Config {
    // fileprivate - https://launchlibrary.net/1.3/launch?next=5
    static let baseURL = "https://launchlibrary.net/1.3/launch"
    static let domain = "com.LaunchLibrary"
}

enum Color {
    static let primaryColor = UIColor(red: 0.22, green: 0.58, blue: 0.29, alpha: 1.0)
    static let secondaryColor = UIColor.lightGray
    
    // A visual way to define colours within code files is to use #colorLiteral
    // This syntax will present you with colour picker component right on the code line
//    static let tertiaryColor = #colorLiteral(r: g: b: a: )
    static let tertiaryColor = #colorLiteral(red: 0.22, green: 0.58, blue: 0.29, alpha: 1.0)
}
