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
    var launches = RocketLaunches() // DELETE ME?
    var launchCollection = [RocketLaunches]()
    
    
    // Create NSSet of the sections, this is for every month in the next year
    // Use NSSet so we can access 'containsObject'
    var sections: NSSet = {
        var array: [Date] = []
        var month: Date?
        for i in 0...12 { // 1->12 (12 = 1 year = current max)
            month = Calendar.current.date(byAdding: .month, value: i, to: Date())
            if let date = month {
                array.append(date)
            }
            
        }
        return NSSet(array: array)
    }()
    
    
    // Setting this property to true will automatically load more launches
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
                //print("attempting to load launches")
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
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(notification:)), name: NSNotification.Name(rawValue: Config.smallImageComplete), object: nil)
    }
    
    func updateUI(notification: NSNotification) {
        // setting isLoading to 'false' will refresh UI
        //isLoading = false

        guard let rocket = notification.userInfo?["rocket"] as? Rocket else {
            print("Error: RocketLaunchesModel.updateUI() -> Rocket is not Rocket?")
            return
        }
        
        // Update corresponding cells for rocket updates
        let indexPath = indexPathForRocket(rocket)
        DispatchQueue.main.async {
            // Must update individual cell to avoid lagging UI
            if let v = self.view as? LaunchesTableController {
                v.tableView.reloadRows(at: indexPath, with: .fade)
                return
            }
            if let v = self.view as? LaunchesGridController {
                v.collectionView?.reloadItems(at: indexPath)
                return
            }
        }
        
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
//            self.seperateIntoSections(collection:rocketLaunches)
            
            self.isLoading = false
            completed()
        })
    }
    
    func seperateIntoSections(collection:[RocketLaunch]?) {
        
        guard let collection = collection else {
            print("Error: data is nil")
            return
        }
        
        // 1. Enumerate through returned launches
        // 2. Get Date (formatted) of each launch
        // 3. Add the launch to launches
        // 4. If we hit a new Month, append launches to collection and start a new array of launches
        
        
        
        // make class property
//        var launchCollection = [RocketLaunches]()
        
        for (_, _) in sections.allObjects.enumerated() {
            let launches3 = createSectionFor(collection)
            launchCollection.append(launches3)
        }
        
        print(launchCollection)
        
        
    }
    
    func createSectionFor(_ collection:[RocketLaunch]) -> RocketLaunches {
        let launches2 = RocketLaunches()
        
        // Build the launches into thier sections
        for (_, launch) in collection.enumerated() {
            if let date = launch.date {
                let calendar = NSCalendar.current
                let components = calendar.dateComponents([.year, .month], from: date)
                let month = calendar.date(from: components)
                //print(month!)
                
                // if the item's date equals the section's date then add it
                if sections.contains(month as Any) {
                    launches2.collection?.append(launch)
                }
            } else {
                print("Error creating sections")
            }
            
            
            
        }
        
        return launches2
        
    }
}

// MARK: - Public Utility Function
extension RocketLaunchesModel {
    func launchForIndexPath(_ indexPath: IndexPath) -> RocketLaunch {
        return launches.collection?[(indexPath as NSIndexPath).row] ?? RocketLaunch()
    }
    fileprivate func indexPathForRocket(_ rocket: Rocket) -> [IndexPath] {
        let section = 0
        
        guard let collection = launches.collection else {
            print("No launches available")
            return []
        }
        
        // Enumerate over all launches in collection
//        let indexPaths = launches.enumerated().flatMap() { (section, collection) in
        let indexPaths = collection.enumerated().filter() { (_, aLaunch) in
                aLaunch.rocket == rocket
                }.map { (row, _) in
                    IndexPath(row: row, section: section)
//        }
        }
        
        return indexPaths
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
