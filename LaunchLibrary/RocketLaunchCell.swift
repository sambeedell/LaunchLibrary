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
