//
//  RocketLaunchVC.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 23/01/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit

class RocketLaunchVC: UIViewController { // Should be a UIScrollView
    var launch : RocketLaunch!
    var rocket : Rocket!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var agenciesLabel: UILabel!
    @IBOutlet var rocketImage: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Include UI updates...
        // activityIndicator.addToSuperview()
        
        // Ensure we have our RocketLaunch object
        guard (launch != nil) else {
            print(NSError(domain: "Dev.segueToLaunch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unable to find information on rocket launch"]))
            return
        }
        
        // Do some UI updates...
        // activityIndicator.removeFromSuperview()
        
        // Check for saved launches
        let defaults = UserDefaults.standard
        if let _ = defaults.object(forKey: "\(launch.id)") {
            toggleSaveButton()
        }
        
        // Display properties of the launch
        rocket = launch.rocket as Rocket
        nameLabel.text = rocket.name
        agenciesLabel.text = "Agencies Involved: \n"
        for agency in rocket.agencies {
            if let name = agency["name"] as? String {
                agenciesLabel.text = "\(agenciesLabel.text!)\n\n\(name)"
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        guard   let url = URL(string: rocket.imageString),
            let imageData = try? Data(contentsOf: url as URL),
            let image = UIImage(data: imageData) else {
                // Return placeholder image
                rocketImage.image = UIImage(named:"no-image-placeholder.jpg")!
                return
        }
        rocketImage.image = image
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // TODO: Save launch
//        let defaults = UserDefaults.standard
        // Encode the RocketLaunch object into NSData before storing to UserDefaults
//        defaults.set(NSKeyedArchiver.archivedDataWithRootObject(launch), forKey: "\(launch.id)")
        toggleSaveButton()
        
    }
    
    func toggleSaveButton() {
        // Update UIBarButtonItem
        saveButton.title = "Saved"
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
}
