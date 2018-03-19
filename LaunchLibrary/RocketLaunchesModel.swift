//
//  RocketLaunchesModel.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 13/03/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Foundation

//protocol RocketLaunchModelDelegate {
//    func savedPressedWith(launch: RocketLaunch) -> ()
//}
// not struct?
class RocketLaunchesModel: NSObject {
    // MARK: - Properties
    var launches = RocketLaunches()
    dynamic var isLoading: Bool = false
    // -> TODO: change from KVO (prone for error due to variable name change and requirement for deinit of observer).
//    var isLoading: Bool = false {
//        didSet {
//            if (view != nil) {
//                print("Loading \(isLoading)")
//                view?.isWaitingForData(isLoading)
//            }
//        }
//    }
    
    // Weak reference to the view
    weak var view: RocketLaunchesController?
    weak var viewCell: RocketLaunchController? {
        didSet {
            print("viewCell referenced correctly")
            viewCell?.delegate = self
        }
    }
    
    // KeyPaths
    let isLoadingKey = #keyPath(RocketLaunchesModel.isLoading)
    
    fileprivate let amount = 50
    
    // Init with dependancy injection
    init(view: RocketLaunchesController) {
        super.init()
        self.view = view
        // Use KVO to communicate changes to protocol
        self.addObserver(self, forKeyPath: isLoadingKey, options: [.new], context: nil)
    }
    
    func fetchLaunches(completed: @escaping () -> ()) {
        isLoading = true
        NetworkService.sharedInstance.fetchRocketLaunches(amount: amount, completionHandler: { [unowned self] (rocketLaunches) in
            // TODO: Should be weak reference to self in this completion handler...
            print("Found: \(rocketLaunches?.count) Launches")
            self.launches.collection = rocketLaunches
            self.isLoading = false
            completed()
        })
    }
    
    
    // MARK: KVO - observing values
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //print("KVO observed change: \(keyPath)")
        if keyPath == isLoadingKey {
            // Tell Controller to start/stop activity monitor
            view?.isWaitingForData(isLoading)
        }
    }
    
    func isLaunchSavedFor(id: Int) -> RocketLaunch? {
        // Check for saved launches
        let defaults = UserDefaults.standard
        if let savedLaunchData = defaults.object(forKey: "\(id)") as? Data,
            let savedLaunch = NSKeyedUnarchiver.unarchiveObject(with: savedLaunchData) as? RocketLaunch {
            return savedLaunch
        }
        print("Launch not found in NSUserDefaults for id \(id)")
        return nil
    }
    
}

extension RocketLaunchesModel: RocketLaunchControllerDelegate {
    func savedButtonPressed(launch: RocketLaunch) {
        // Save launch
        let defaults = UserDefaults.standard
        // Encode the RocketLaunch object into NSData before storing to UserDefaults
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: launch), forKey: "\(launch.id)")
    }
}



// Include animation when items added
//tableView.beginUpdates()
//tableView.insertRows()
//tableView.endUpdates()