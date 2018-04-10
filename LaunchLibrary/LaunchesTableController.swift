//
//  RocketLaunchesController.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 23/01/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit
import Hero

class LaunchTableCell2: UITableViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
}

class LaunchesTableController: UITableViewController {
    
    // Connect to Model - must have
    var viewModel: RocketLaunchesModel! {
        didSet {
            viewModel.view = self
        }
    }
    
    // Identifiers
    let reuseIdentifier = "launchTableCell"
    
    // Create Activity Indicator
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    // Delegate method
    weak var delegate: RocketLaunchesControllerDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view, typically from a nib.
//        let nib = UINib(nibName: "LaunchTableCell", bundle: nil)
//        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        
        // Position Activity Indicator in the center of the main view
        activityIndicator.center = tableView.center
        
        // Acivity Indicator is hidden when stopAnimating() is called
        activityIndicator.hidesWhenStopped = true
        
        // Add AI to tableview
        tableView.addSubview(activityIndicator)
    }

    func refreshViewAsync() {
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    @IBAction func toGrid(_ sender: Any) {
        let next = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "grid") as? LaunchesGridController)!
        next.collectionView?.contentOffset.y = tableView.contentOffset.y + tableView.contentInset.top
        next.viewModel = viewModel
        hero.replaceViewController(with: next)
    }
}

// MARK: - UITableViewDataSource
extension LaunchesTableController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Not sure this follows the MVVM design architecture
        // Display current Launch
        let launch = viewModel.launchForIndexPath(indexPath)
        delegate?.displaySelectionFor(launch)
        //performSegue(withIdentifier: "segueToLaunch", sender: indexPath)
        
        // Ensure correct functionality for iPhone
        if let detailViewController = delegate as? LaunchDetailController {
            
            detailViewController.selectedIndex = indexPath
            detailViewController.delegate = viewModel
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad
                // Segue using split view
                splitViewController?.showDetailViewController(detailViewController, sender: nil)
            } else {
                // iPhone
                // Segue using nav controller for correct transition animation
                navigationController?.pushViewController(detailViewController, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LaunchTableCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LaunchTableCell2
        cell.backgroundColor = UIColor.clear
        cell.tag = indexPath.row
        
        // Get the correct launch for the row
        let launch = viewModel.launchForIndexPath(indexPath)
        if let image = launch.rocket?.smallImage {
            // Use smaller image
            cell.cellImage.image = image
        } else {
            // Use placeholder image
            cell.cellImage.image = launch.rocket?.image
        }
        
        cell.cellLabel.text = launch.name
        // TODO: Additional details....
        
        
        
        // Integrate Hero
        cell.hero.modifiers = [.fade, .translate(x:-100)]
        cell.cellImage.hero.id = "image_\(indexPath.item)"
        cell.cellImage.hero.modifiers = [.arc]
//        cell.backgroundColor = image?.averageColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Header"
        label.backgroundColor = .lightGray
        return label
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.launches.collection?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Nib aspect ratio = 2.7 : 1
        return self.view.bounds.size.width / 2.5
    }
    
    // TODO: Load more launches when user scrolls to the bottom?
}

extension LaunchesTableController: RocketLaunchesControllerDelegate {
    func isWaitingForData(_ isLoading: Bool) {
        DispatchQueue.main.async {
            isLoading ? self.startSpinner() : self.stopSpinner()
        }
    }
    
    func startSpinner() {
        // Start Activity Indicator
        activityIndicator.startAnimating()
    }
    
    func stopSpinner() {
        // Stop activity indicator
        activityIndicator.stopAnimating()
    }
}

extension LaunchesTableController: HeroViewControllerDelegate {
    func heroWillStartAnimatingTo(viewController: UIViewController) {
        if let _ = viewController as? LaunchesGridController {
            tableView.hero.modifiers = [.ignoreSubviewModifiers]
//        } else if viewController is ImageViewController {
        } else {
            tableView.hero.modifiers = [.cascade]
        }
    }
    
    func heroWillStartAnimatingFrom(viewController: UIViewController) {
        if let _ = viewController as? LaunchesGridController {
            tableView.hero.modifiers = [.ignoreSubviewModifiers]
        } else {
            tableView.hero.modifiers = [.cascade]
        }
        // TODO: Does this need to be incorporated?
//        if let vc = viewController as? LaunchDetailController,
//            let originalCellIndex = vc.selectedIndex,
//            let currentCellIndex = vc.collectionView?.indexPathsForVisibleItems[0] {
//            if tableView.indexPathsForVisibleRows?.contains(currentCellIndex) != true {
//                // make the cell visible
//                tableView.scrollToRow(at: currentCellIndex,
//                                      at: originalCellIndex < currentCellIndex ? .bottom : .top,
//                                      animated: false)
//            }
//        }
    }
}
