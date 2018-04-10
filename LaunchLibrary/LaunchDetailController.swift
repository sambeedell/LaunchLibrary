//
//  RocketLaunchVC.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 23/01/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit

protocol RocketLaunchControllerDelegate: class {
    func savedButtonPressed(launch: RocketLaunch) -> ()
}

class LaunchDetailController: UIViewController { // Should be a UIScrollView
    
    var selectedIndex: IndexPath?
    
    // TODO: Add Activity Indicator to image placeholder while image is loading...
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var agenciesLabel: UILabel!
    @IBOutlet var rocketImage: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    var launch: RocketLaunch! {
        didSet {
            if let rocket = launch.rocket {
                loadUIElements(rocket)
            }
            // Update save state
            launchSaved = launch.isSaved
        }
    }
    var launchSaved: Bool! {
        didSet {
            toggleSaveButton(launchSaved)
        }
    }
    
    weak var delegate: RocketLaunchControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadUIElements(_ rocket: Rocket) {
        // Display properties of the rocket
        navigationItem.title = rocket.name
        nameLabel.text = launch.launchFrom
        agenciesLabel.text = "Agencies Involved: \n"
        if let agencies = rocket.agencies {
            for agency in agencies {
                if let name = agency["name"] as? String {
                    agenciesLabel.text = "\(agenciesLabel.text!)\n\n\(name)"
                }
            }
        } else {
            agenciesLabel.text = "\(agenciesLabel.text!)\n\nNone"
        }
        rocketImage.image = rocket.image
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Save to NSUserDefaults
        // TODO: No completion handler?
        if let delegate = delegate {
            // Update launch
            launch.isSaved = true
            delegate.savedButtonPressed(launch: launch)
            // Update UI
            launchSaved = true
        }
    }
    
    func toggleSaveButton(_ saved: Bool) {
        // Update UIBarButtonItem
        saveButton.title = saved ? "Saved" : "Save"
        self.navigationItem.rightBarButtonItem?.isEnabled = !saved
    }
}

extension LaunchDetailController: RocketLaunchesControllerDataSource {
    func displaySelectionFor(_ newLaunch: RocketLaunch) {
        launch = newLaunch
    }
}
