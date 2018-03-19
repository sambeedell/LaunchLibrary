//
//  RocketLaunchesVC.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 23/01/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit

class RocketLaunchesVC: UITableViewController {
    
    // MARK: - Properties
    fileprivate let reuseIdentifier = "rocketLaunchCell"
    fileprivate var launches = [RocketLaunches]()
    fileprivate let api = LaunchLibraryAPI()
    fileprivate let amount = 50
    
    var isLoading : Bool = false
    
    // Create Activity Indicator
    var activityIndicator : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let nib = UINib(nibName: "RocketLaunchCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        
        loadData()
    }
    
    func loadData() {
        if isLoading == false  {
            // Do some UI updates...
            startSpinner()
            isLoading = true
            
            // TODO: Load less at a time to reduce loading time
            api.searchLibraryForLaunch(amount: amount) {
                results, error in
                // Do some UI updates...
                self.stopSpinner()
                
                if let error = error {
                    print("Error searching : \(error)")
                    return
                }
                if let results = results {
                    print("Stored \(results.collection.count) launches correctly")
                    self.launches.insert(results, at: self.launches.count)
                    // TODO: Populate TableView using an animation (because it looks nice)
                    self.tableView?.reloadData()
                    self.isLoading = false
                }
            }
        }
    }
    
    func startSpinner() {
        if activityIndicator == nil {
            //Create Activity Indicator
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            
            // Position Activity Indicator in the center of the main view
            activityIndicator.center = tableView.center
            
            // Acivity Indicator is hidden when stopAnimating() is called
            activityIndicator.hidesWhenStopped = true
            
            // Add AI to tableview
            self.tableView.addSubview(activityIndicator)
        }
        
        // Start Activity Indicator
        activityIndicator.startAnimating()
    }
    
    func stopSpinner() {
        // Stop activity indicator
        activityIndicator.stopAnimating()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueToLaunch", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get current Launch
        let launch = launchForIndexPath(sender as! IndexPath)
        
        if segue.identifier == "segueToLaunch" {
            // Get a reference to the second view controller
            let vc = segue.destination as! RocketLaunchVC
            // Set properties...
            vc.launch = launch
        }
        
    }
    
}

// MARK: - Private
private extension RocketLaunchesVC {
    func launchForIndexPath(_ indexPath: IndexPath) -> RocketLaunch {
        return launches[(indexPath as NSIndexPath).section].collection[(indexPath as NSIndexPath).row]
    }
}

// MARK: - UITableViewDataSource
extension RocketLaunchesVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return launches.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return launches[section].collection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RocketLaunchCell
        cell.backgroundColor = UIColor.clear
        
        // Get the correct launch for the row
        let launch = launchForIndexPath(indexPath)
        // Format Date and Status
        let date = String(launch.date.characters.dropLast(12)) // Remove Time!
        let status : String = launch.status == true ? "Ok!" : "Unlikely..."
        // Init the Nib properties
        cell.commonInit(date: date,
                        name: launch.name,
                        status: "Status: \(status)",
                        info: "Launch Window: \(launch.launchWindow.first!) - \(launch.launchWindow.last!)")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Nib aspect ratio = 2.7 : 1
        return self.view.bounds.size.width / 2.5
//        return 185
    }
    
    // MARK: UICollectionViewDelegate
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.item == (launches[indexPath.section].collection.count - 5){
//            // Do something
//            loadData()
//        }
//    }
}


// TODO: Check for stored data (RocketLaunches)
// Check for any stored matches to LaunchID then restore the RocketLaunch data by unarchiving
//let defaults = UserDefaults.standard
//if let data = defaults.objectForKey("\(launch.id)") as? NSData {
//    let unarc = NSKeyedUnarchiver(forReadingWithData: data)
//    unarc.setClass(RocketLaunch.self, forClassName: "RocketLaunch")
//    let launch = unarc.decodeObjectForKey("root")
//}

