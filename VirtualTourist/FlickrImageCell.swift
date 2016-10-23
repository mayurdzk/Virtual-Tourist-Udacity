//
//  FlickrImageCell.swift
//  VirtualTourist
//
//  Created by Mayur on 23/10/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import UIKit

class FlickrImageCell: UICollectionViewCell{
    @IBOutlet var flickrImageImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        if flickrImageImageView.image == nil{
            activityIndicator.startAnimating()
            self.backgroundColor = UIColor.blue
        }
        else{
            activityIndicator.stopAnimating()
            self.backgroundColor = nil
        }
    }
}
