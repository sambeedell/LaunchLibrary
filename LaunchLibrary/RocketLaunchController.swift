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

class RocketLaunchController: UIViewController { // Should be a UIScrollView
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var agenciesLabel: UILabel!
    @IBOutlet var rocketImage: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    var launch: RocketLaunch!
    var launchSaved: Bool!
    
    weak var delegate: RocketLaunchControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let launchToDisplay = launch, let rocket = launchToDisplay.rocket else { return }
        loadUIElements(rocket: rocket)
        guard let unwrappedBool = launchSaved else { return }
        if unwrappedBool { toggleSaveButton() }
    }
    
    func loadUIElements(rocket: Rocket) {
        // Display properties of the rocket
        nameLabel.text = rocket.name
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
            delegate.savedButtonPressed(launch: launch)
            // Update UI
            toggleSaveButton()
        }
    }
    
    func toggleSaveButton() {
        // Update UIBarButtonItem
        saveButton.title = "Saved"
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
}
