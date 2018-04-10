//
//  LaunchesGridController.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 06/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit
import Hero

class GridCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
}

class LaunchesGridController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // Connect to Model - must have
    var viewModel: RocketLaunchesModel! {
        didSet {
            viewModel.view = self
        }
    }
    
    // Delegate method
    weak var delegate: RocketLaunchesControllerDataSource?
    
    // TODO: Do this for TableView AIView
    // UI Properties
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Unwrap collection view
        if let cv = collectionView {
            // Position Activity Indicator in the center of the main view
            activityIndicator.center = cv.center
            
            // Acivity Indicator is hidden when stopAnimating() is called
            activityIndicator.hidesWhenStopped = true
            
            // Add AI to collectionView
            cv.addSubview(activityIndicator)
        }
    }
    
    func refreshViewAsync() {
        DispatchQueue.main.async { [unowned self] in
            self.collectionView?.reloadData()
        }
    }
    
    @IBAction func toList(_ sender: Any) {
        let next = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "table") as? LaunchesTableController)!
        next.tableView.contentOffset.y = collectionView!.contentOffset.y + collectionView!.contentInset.top
        next.viewModel = viewModel
        hero.replaceViewController(with: next)
    }
}

extension LaunchesGridController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: Repeated CODE
        // Display current Launch
        let launch = viewModel.launchForIndexPath(indexPath)
        delegate?.displaySelectionFor(launch)
        //performSegue(withIdentifier: "segueToLaunch", sender: indexPath)
        
        // Ensure correct functionality for iPhone
        if let detailViewController = delegate as? LaunchDetailController {
            // Set properties
            detailViewController.selectedIndex = indexPath
            detailViewController.delegate = viewModel
            
            // Process segue based on device
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
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as? GridCell)!
        let launch = viewModel.launchForIndexPath(indexPath)
        let image = launch.rocket?.smallImage
        cell.hero.modifiers = [.fade, .translate(y:20)]
        cell.imageView!.image = image
        cell.imageView!.hero.id = "image_\(indexPath.item)"
        cell.imageView!.hero.modifiers = [.arc]
        cell.imageView!.isOpaque = true
        cell.textLabel!.text = "\(launch.name!)"
        //cell.detailTextLabel!.text = "Description \(indexPath.item)"
//        cell.backgroundColor = image?.averageColor
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) 
            headerView.frame.size.height = 100
            let label = UILabel(frame: headerView.frame)
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yy"
            label.text = formatter.string(from: viewModel.sections[indexPath.section])
            label.backgroundColor = .lightGray
            headerView.addSubview(label)
            return headerView
            
//        case UICollectionElementKindSectionFooter:
//            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath) as! UICollectionReusableView
//
//            footerView.backgroundColor = .green
//            return footerView
            
        default:
            
            assert(false, "Unexpected element kind")
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.launchCollection.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.launchCollection[section].collection?.count ?? 0
    }
    
    // UICollectionViewFlowLayout
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        // Dynamic sizing based on content
//        let x = view.frame.width / 250
//        let scale = x - 10
////        let scale = 10 * Int(round(x / 10.0))
//        
//        return CGSize(width: view.frame.width / scale, height: 250)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero // Make(0, 0, 0, 0)
    }
}

// TODO: Repeated Code...
extension LaunchesGridController: RocketLaunchesControllerDelegate {
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

extension LaunchesGridController: HeroViewControllerDelegate {
    
    func heroWillStartAnimatingTo(viewController: UIViewController) {
        if let _ = viewController as? LaunchDetailController,
            let index = collectionView!.indexPathsForSelectedItems?[0],
            let cell = collectionView!.cellForItem(at: index) as? GridCell {
            let cellPos = view.convert(cell.imageView.center, from: cell)
            collectionView!.hero.modifiers = [.scale(3), .translate(x:view.center.x - cellPos.x, y:view.center.y + collectionView!.contentInset.top/2/3 - cellPos.y), .ignoreSubviewModifiers, .fade]
        } else {
            collectionView!.hero.modifiers = [.cascade]
        }
    }
    
    func heroWillStartAnimatingFrom(viewController: UIViewController) {
        // TODO: Update (Detail) view to segue to
//        if let vc = viewController as? LaunchDetailController,
//            let originalCellIndex = vc.selectedIndex,
//            let currentCellIndex = vc.collectionView?.indexPathsForVisibleItems[0] {
//            collectionView!.hero.modifiers = [.cascade]
//            if !collectionView!.indexPathsForVisibleItems.contains(currentCellIndex) {
//                // make the cell visible
//                collectionView!.scrollToItem(at: currentCellIndex,
//                                             at: originalCellIndex < currentCellIndex ? .bottom : .top,
//                                             animated: false)
//            }
//        } else {
            collectionView!.hero.modifiers = [.cascade, .delay(0.2)]
//        }
    }
}

