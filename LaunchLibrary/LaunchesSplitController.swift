//
//  RocketSplitController.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 05/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit

protocol RocketLaunchesControllerDelegate {
    func isWaitingForData(_ isLoading: Bool) -> ()
}

protocol RocketLaunchesControllerDataSource: class {
    func displaySelectionFor(_ newLaunch: RocketLaunch)
}

class LaunchesSplitController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Force Hero enabled (fancy transition animations)
        self.view.hero.isEnabled = true

        // Force the split view to show the master (not detail) for iPhone in portrait
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func splitViewController( _ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
}
