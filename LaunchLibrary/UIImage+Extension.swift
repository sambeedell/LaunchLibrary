//
//  UIImage+Extension.swift
//  LaunchLibrary
//
//  Created by Sam Beedell on 16/03/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import UIKit

extension UIImage {
    
    func imageFromServer(urlString: String, completion: @escaping (UIImage) -> Void) {
        let blank = #imageLiteral(resourceName: "no-image-placeholder")
        guard let url = URL(string: urlString) else { completion(blank); return }
        
        NetworkService.sharedInstance.fetchRocketImage(imageURL: url) { (imageData) in
            if let imageData = imageData,
                let image = UIImage(data: imageData) {
                completion(image)
            } else {
                completion(blank)
            }
        }
    }
}
