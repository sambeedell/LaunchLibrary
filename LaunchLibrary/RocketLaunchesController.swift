//
//  RocketLaunchesController.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 23/01/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit

protocol RocketLaunchesControllerDelegate {
    func isWaitingForData(_ isLoading: Bool) -> ()
}

class RocketLaunchesController: UITableViewController {
    
    // Connect to Model - must have
    var viewModel: RocketLaunchesModel!
    
    // Identifiers
    let reuseIdentifier = "rocketLaunchCell"
    
    // Create Activity Indicator
    var activityIndicator : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let nib = UINib(nibName: "RocketLaunchCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        
        // Create view model instance with dependancy injection
        viewModel = RocketLaunchesModel(view: self)
        viewModel.fetchLaunches {
            DispatchQueue.main.async { [weak self] in
                print(self?.viewModel ?? 0)
                self?.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueToLaunch", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get current Launch
        var launch = launchForIndexPath(sender as! IndexPath)
        if let savedLaunch = viewModel.isLaunchSavedFor(id: launch.id!) {
            launch = savedLaunch
        }
        
        if segue.identifier == "segueToLaunch" {
            // Get a reference to the second view controller
            if let vc = segue.destination as? RocketLaunchController {
                // Set weak reference to new view controller in viewModel
                viewModel.viewCell = vc
                // Set properties...
                vc.launch = launch
            }
        }
    }
    
}


// MARK: - Private
private extension RocketLaunchesController {
    func launchForIndexPath(_ indexPath: IndexPath) -> RocketLaunch {
        return viewModel.launches.collection?[(indexPath as NSIndexPath).row] ?? RocketLaunch()
    }
}

// MARK: - UITableViewDataSource
extension RocketLaunchesController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.launches.collection?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RocketLaunchCell
        cell.backgroundColor = UIColor.clear
        // Get the correct launch for the row
        cell.launch = launchForIndexPath(indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Nib aspect ratio = 2.7 : 1
        return self.view.bounds.size.width / 2.5
    }
    
    // MARK: UICollectionViewDelegate
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.item == (launches[indexPath.section].collection.count - 5){
//            // Do something
//            loadData()
//        }
//    }
}

extension RocketLaunchesController: RocketLaunchesControllerDelegate {
    func isWaitingForData(_ isLoading: Bool) {
        isLoading ? startSpinner() : stopSpinner()
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
            tableView.addSubview(activityIndicator)
        }
        
        // Start Activity Indicator
        activityIndicator.startAnimating()
    }
    
    func stopSpinner() {
        // Stop activity indicator
        activityIndicator.stopAnimating()
    }
}
