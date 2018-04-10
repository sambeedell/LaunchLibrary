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
    var parsedLaunches: RocketLaunches? = RocketLaunches()
    var launchCollection = [RocketLaunches]()
    
    
    // Create NSSet of the sections, this is for every month in the next year
    // Use NSSet so we can access 'containsObject'
    var sections: [Date] = {
        var array: [Date] = []
        var thisMonth: Date = {
            let calendar = NSCalendar.current
            let components = calendar.dateComponents([.year, .month], from: Date()) // Today - this month
            return calendar.date(from: components)!
        }()
        for i in 0...12 { // 1->12 (12 = 1 year = current max)
            if let date = Calendar.current.date(byAdding: .month, value: i, to: thisMonth) {
                array.append(date)
            }
        }
        return array //NSSet(array: array)
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
            if launchCollection.count > 1 {
                // Use stored Launches
                print("using stored launches")
                return
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
            
            if let safe = self.parsedLaunches {
                safe.collection = rocketLaunches
                self.launchCollection = self.getCollectionInSections()
            }
            
            //print("Collection complete and compiled into sections seperated by Month: \(self.launchCollection)")
            
            self.isLoading = false
            completed()
            print("Updating UI...")
        })
    }
    
    func getCollectionInSections() -> [RocketLaunches] {
        
        var tempLaunchCollection = [RocketLaunches]()
        
        // TODO: Check efficiency? -> TEST
        for (_, month) in sections.enumerated() {
            // Create an array of RocketLaunch for each month & append
            let sectionForMonth = createSectionFor(month: month)
            tempLaunchCollection.append(sectionForMonth)
            // Exit quickly if all launches have been processed
            if parsedLaunches?.collection?.count == 0 {
                parsedLaunches = nil
                return tempLaunchCollection
            }
        }
        return tempLaunchCollection
    }
    
    func createSectionFor(month: Date) -> RocketLaunches {
        
        guard let collection = parsedLaunches?.collection else {
            print("Error: data is empty")
            return RocketLaunches() // -> return empty object
        }
        
        // Create a collection of RocketLaunch(es)
        var section = [RocketLaunch]()
        
        // Enumerate through all launches in collection
        for (_, launch) in collection.enumerated() {
            if let date = launch.date {
                let calendar = NSCalendar.current
                let components = calendar.dateComponents([.year, .month], from: date)
                let launchDate = calendar.date(from: components)
                // Build the launches into thier sections
                if let launchDate = launchDate {
                    //print("\(month) == \(launchDate)")
                    if month == launchDate {
                        //print("Added launch for date: \(month)")
                        //print(launch)
                        section.append(launch)
                    } else {
                        //print("no")//"Launch not found for date: \(month)")
                    }
                    
                    // if the item's date equals the section's date then add it
                    //if sections.contains(month) {
                        
                } else {
                    print("Error creating sections")
                }
            } else {
                print("Error creating sections")
            }
        }
        
        // Create the RocketLaunches object and SET it's collection
        let rocketLaunches = RocketLaunches()
        rocketLaunches.collection = section
        
        // Remove finished values (cannot mutate while enumerating)
        parsedLaunches?.collection = collection.filter { !section.contains($0) }
        
        print("Found: \(section.count) launches in \(month), \(parsedLaunches?.collection?.count ?? 0) remaining")
        
        return rocketLaunches
        
    }
}

// MARK: - Public Utility Function
extension RocketLaunchesModel {
    func launchForIndexPath(_ indexPath: IndexPath) -> RocketLaunch {
        return launchCollection[indexPath.section].collection?[(indexPath as NSIndexPath).row] ?? RocketLaunch()
    }
    fileprivate func indexPathForRocket(_ rocket: Rocket) -> [IndexPath] {
        // https://stackoverflow.com/questions/31082833/use-a-functional-technique-to-discover-an-nsindexpath?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
        // Enumerate over all launches in collection
        let indexPaths = launchCollection.enumerated().flatMap() { (section, launches) in
            launches.collection?.enumerated().filter() { (_, aLaunch) in
                aLaunch.rocket == rocket
                }.map { (row, _) in
                    IndexPath(row: row, section: section)
            }
        }
        // TODO: Check here
        return indexPaths.first ?? []
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

