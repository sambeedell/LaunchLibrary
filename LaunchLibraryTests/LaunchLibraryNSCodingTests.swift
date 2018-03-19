//
//  LaunchLibraryNSCodingTests.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 06/03/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import XCTest
@testable import LaunchLibrary

class LaunchLibraryNSCodingTests: XCTestCase {
    
    var rocketLaunch : RocketLaunch!
    var rocket : Rocket!
    
    override func setUp() {
        super.setUp()
        
        // Create rocket
        rocket = self.rocketInit(name: "rocket")
        
        // Create rocket launch
        rocketLaunch = self.rocketLaunchInit(name: "rocketLaunch", rocket: rocket)
    }
    
    // TODO: Test that Rocket / RocketLaunch conforms to NSCoding?
    // <Rocket:NSCoding>
    func rocketInit(name: String) -> Rocket {
        let output = Rocket(id: 0, name: name, agencies: [["Agency":"n/a" as AnyObject]], imageString: "n/a")
        return output
    }
    func rocketLaunchInit(name: String, rocket: Rocket) -> RocketLaunch {
        let output = RocketLaunch(id: 0, name: name, status: true, date: "n/a", launchWindow: [0], launchFrom: "here", whereToWatch: "there", rocket: rocket)
        return output
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        rocket = nil
        rocketLaunch = nil
        super.tearDown()
    }
    
    // Test NSKeyedArchiver by cloning
    func testRocketClone() {
        let data = NSKeyedArchiver.archivedData(withRootObject: rocket)
        if let result = NSKeyedUnarchiver.unarchiveObject(with: data) as? Rocket {
            XCTAssertEqual("rocket", result.name)
            XCTAssertEqual("n/a", result.imageString)
        } else {
            XCTFail("Rocket() cannot be encoded")
        }
    }
    
    func testRocketLaunchClone() {
        let data = NSKeyedArchiver.archivedData(withRootObject: rocketLaunch)
        if let result = NSKeyedUnarchiver.unarchiveObject(with: data) as? RocketLaunch {
            XCTAssertEqual("rocketLaunch", result.name)
            XCTAssertEqual(rocket.name, result.rocket.name)
            //XCTAssertNotEqual(rocket, result.rocket) // WHY - Is this testing address/pointer values rather than content?
            //XCTAssertTrue(rocket == result.rocket) // === tests reference types rather than Equatable
        } else {
            XCTFail("RocketLaunch() cannot be encoded")
        }
    }
    
    // Ensure archiving custom objects is working
    func testUserDefaults() {
        
        // Create key
        let key = "\(rocketLaunch.id)"
        
        // Encode the RocketLaunch object into NSData before storing to UserDefaults
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: rocketLaunch)
        
        UserDefaults.blankDefaultsWhile {
            
            // Save launch
            let defaults = UserDefaults.standard
            defaults.set(encodedData, forKey: key)
            
            // Check for saved launches
            unarchiving: if let savedLaunchData = defaults.object(forKey: key) as? Data {
                guard let savedLaunch = NSKeyedUnarchiver.unarchiveObject(with: savedLaunchData) as? RocketLaunch else {
                    XCTFail("unable to unarchive saved launch")
                    break unarchiving
                }
                XCTAssertEqual("rocketLaunch", savedLaunch.name)
                XCTAssertEqual(savedLaunch.rocket.name, rocket.name)
            }
        }
        
        // Ensure we have returned UserDefaults to previous state
        XCTAssertTrue(UserDefaults.standard.object(forKey: key) == nil)
        
    }
    
}

extension UserDefaults {
    
    static func blankDefaultsWhile(handler:() -> Void){
        guard let name = Bundle.main.bundleIdentifier else {
            fatalError("Couldn't find bundle ID.")
        }
        let old = UserDefaults.standard.persistentDomain(forName: name)
        defer {
            UserDefaults.standard.setPersistentDomain( old ?? [:],
                                      forName: name)
        }
        
        UserDefaults.standard.removePersistentDomain(forName: name)
        handler()
    }
}
