//
//  RocketLaunchCell.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 24/01/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit

class RocketLaunchCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    
    var launch: RocketLaunch? {
        didSet {
            // Format Properties
            if let date = launch?.date {
                dateLabel.text = String(date.characters.dropLast(12)) // Remove Time!
            }
            if let status = launch?.status {
                let statusString : String = status == true ? "Ok!" : "Unlikely..."
                statusLabel.text = statusString
            }
            if let name = launch?.name {
                nameLabel.text = name
            }
            if let info = launch?.launchWindow {
                infoLabel.text = "Launch Window: \(info.first!) - \(info.last!)"
            }
        }
    }
    
    func commonInit (date: String, name : String, status : String, info : String) {
        dateLabel.text = date
        nameLabel.text = name
        statusLabel.text = status
        infoLabel.text = info
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
