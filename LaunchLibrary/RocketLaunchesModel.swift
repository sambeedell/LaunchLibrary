//
//  RocketLaunchesModel.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 13/03/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Foundation

// TODO: Remove print statements / wrap in DEBUG

// TODO: Make struct?
class RocketLaunchesModel: NSObject {
    // MARK: - Properties
    var launches = RocketLaunches()
    var isLoading: Bool = false {
        didSet {
            view?.isWaitingForData(isLoading)
        }
    }
    
    // How many launches we wish to download
    fileprivate let amount = 50
    
    // Weak reference to the view
    weak var view: RocketLaunchesController?
    weak var viewCell: RocketLaunchController? {
        didSet {
            viewCell?.delegate = self
        }
    }
    
    // Init with dependancy injection
    init(view: RocketLaunchesController) {
        super.init()
        self.view = view
    }
    
    func fetchLaunches(completed: @escaping () -> ()) {
        isLoading = true
        NetworkService.sharedInstance.fetchRocketLaunches(amount: amount, completionHandler: { [unowned self] (rocketLaunches) in
            // TODO: Should be weak reference to self in this completion handler...
            print("Found: \(rocketLaunches!.count) Launches")
            self.launches.collection = rocketLaunches
            self.isLoading = false
            completed()
        })
    }
    
    func isLaunchSavedFor(launchId: Int) -> Bool {
        // Check for saved launches
        let defaults = UserDefaults.standard
        if let _ = defaults.object(forKey: "\(launchId)") as? Data {
            //let savedLaunch = NSKeyedUnarchiver.unarchiveObject(with: savedLaunchData) as? RocketLaunch
            //print("Launch found in NSUserDefaults for launch id \(launchId)")
            return true
        }
        //print("Launch not found in NSUserDefaults for launch id \(launchId)")
        return false
    }
    
}

extension RocketLaunchesModel: RocketLaunchControllerDelegate {
    func savedButtonPressed(launch: RocketLaunch) {
        if let launchId = launch.id {
            // Save launch
            let defaults = UserDefaults.standard
            // Encode the RocketLaunch object into NSData before storing to UserDefaults
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: launch), forKey: "\(launchId)")
        }
    }
}



// Include animation when items added
//tableView.beginUpdates()
//tableView.insertRows()
//tableView.endUpdates()
