//
//  ProgressHUD.swift
//  VirtualTourist
//
//  Created by Mayur on 08/07/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import UIKit

//Imported from Github and migrated to Swift 3
class ProgressHUD: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)
        self.setup()
        
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(activityIndictor)
        vibrancyView.contentView.addSubview(label)
        activityIndictor.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = (UIApplication.shared.delegate as! AppDelegate).window {
            
            let width = superview.frame.size.width / 2.3 + 30
            let height: CGFloat = 50.0
            let centerOfSuperView = superview.center
            
            self.frame = CGRect(x: centerOfSuperView.x - width / 2,
                                y: centerOfSuperView.y - height / 2,
                                width: width,
                                height: height)
            self.center = centerOfSuperView
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame = CGRect(x: 5, y: height / 2 - activityIndicatorSize / 2,
                                            width: activityIndicatorSize,
                                            height: activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = text
            label.textColor = UIColor.black
            label.textAlignment = NSTextAlignment.center
            label.frame = CGRect(x: activityIndicatorSize + 5, y: 0, width: width - activityIndicatorSize - 15, height: height)
            label.textColor = UIColor.black
            label.font = UIFont.boldSystemFont(ofSize: 16)
        }
    }
    
    func show() {
        self.isHidden = false
        superview?.isUserInteractionEnabled = false
    }
    
    func hide() {
        self.isHidden = true
        superview?.isUserInteractionEnabled = true
    }
}
