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
            if let v = view as? LaunchesTableController {
                fetchLaunches {
                    // When completed...
                    v.refreshViewAsync()
                }
                v.isWaitingForData(isLoading)
                return
            }
            if let v = view as? LaunchesGridController {
                fetchLaunches {
                    // When completed...
                    v.refreshViewAsync()
                }
                v.isWaitingForData(isLoading)
                return
            }
        }
    }
    
    // How many launches we wish to download
    fileprivate let amount = 20
    
    // Weak reference to the view - for dependancy injection
    weak var view: AnyObject! {
        // When the view is set, we need some data to display...
        didSet {
            if let count = launches.collection?.count {
                if count > 1 {
                    // Use stored Launches
                    print("using stored launches")
                    return
                }
            } else {
                // Load Launches
                print("attempting to load launches")
                isLoading = true
            }
        }
    }
    
    weak var viewCell: LaunchDetailController? {
        didSet {
            viewCell?.delegate = self
        }
    }
    
    override init() {
        super.init()
        //NotificationCenter.default.addObserver(self, selector: #selector(updateUI(forNotification:)), name: NSNotification.Name(rawValue: Config.smallImageComplete), object: nil)
    }
    
    func updateUI(forNotification notification: NSNotification) {
        // setting isLoading to 'false' will refresh UI
        //isLoading = false
//
//        print(notification.userInfo?["rocketID"])
//
//        guard let rocket = notification.userInfo?["rocket"] else {
//            print("no rocket found")
//            return
//        }
//
//        guard let _ = rocket as? Rocket else {
//            print("rocket is not rocket?")
//            return
//        }
//
//        if let rocket = notification.userInfo?["rocket"] as? Rocket {
        
        if let rocketName = notification.userInfo?["rocketName"] as? String {
            // Search for indexPath
            let indexPath = getIndexPath(forRocket: rocketName)
            print(indexPath) // Must NOT be an array
            
            DispatchQueue.main.async {
                // Must update individual cell to avoid lagging UI
                if let v = self.view as? LaunchesTableController {
                    v.tableView.reloadRows(at: indexPath, with: .top)
                    return
                }
                if let v = self.view as? LaunchesGridController {
                    v.collectionView?.reloadItems(at: indexPath)
                    return
                }
            }
        }
    }
    
    fileprivate func getIndexPath(forRocket rocket: String) -> [IndexPath] {
        print(rocket)
        // Enumerate over all launches in collection
        // Process each object by filtering for match case
        let indexPaths = launches.collection?.enumerated().filter() { (section, launch) in
            // If launch has matching rocket object
            launch.rocket?.name == rocket
            }.map { (row, _) in
                // Process matching object
                IndexPath(row: row, section: 1)
        } ?? []
        
        return indexPaths
    }
    
    func fetchLaunches(completed: @escaping () -> ()) {
        // Ensure we are not already loading
        guard isLoading else {
            completed()
            return
        }
        print("loading launches")
        // Fetch Launches using Network Request
        NetworkService.sharedInstance.fetchRocketLaunches(amount: amount, completionHandler: { [unowned self] (rocketLaunches) in
            // TODO: Should be weak reference to self in this completion handler...
            print("Found: \(rocketLaunches!.count) Launches")
            self.launches.collection = rocketLaunches
            self.isLoading = false
            completed()
        })
    }
}

// MARK: - Public Utility Function
extension RocketLaunchesModel {
    func launchForIndexPath(_ indexPath: IndexPath) -> RocketLaunch {
        return launches.collection?[(indexPath as NSIndexPath).row] ?? RocketLaunch()
    }
}

// MARK: - Delegate Handling
extension RocketLaunchesModel: RocketLaunchControllerDelegate {
    func savedButtonPressed(launch: RocketLaunch) {
        if let launchId = launch.id {
            // Save launch
            let defaults = UserDefaults.standard
            // Encode the RocketLaunch object into NSData before storing to UserDefaults
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: launch), forKey: "\(launchId)")
            print("Rocket Launch Saved: \(launchId)")
        }
    }
}



// Include animation when items added
//tableView.beginUpdates()
//tableView.insertRows()
//tableView.endUpdates()
