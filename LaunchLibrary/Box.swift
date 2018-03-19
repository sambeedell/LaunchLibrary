//
//  Box.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 19/03/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Foundation

class Box<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    var value: T {
        didSet {
            // Notify Listeners
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
