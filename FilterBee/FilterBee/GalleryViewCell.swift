//
//  GalleryViewCell.swift
//  FilterBee
//
//  Created by Brian Ledbetter on 1/12/15.
//  Copyright (c) 2015 Brian Ledbetter. All rights reserved.
//

import UIKit

class GalleryViewCell: UICollectionViewCell {
  let imageView = UIImageView()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(self.imageView)
    self.backgroundColor = UIColor.lightGrayColor()
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.frame = self.bounds
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 16.0
    imageView.backgroundColor = UIColor.lightGrayColor()
    let views = ["imageView" : self.imageView]
    
    // set up constraints
    setAutoLayoutConstraints(forViews: views)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func setAutoLayoutConstraints(forViews views : [String : AnyObject]){
    let imageViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: nil, metrics: nil, views: views)
    self.addConstraints(imageViewConstraintsHorizontal)
    
    let imageViewConstraintsVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: nil, metrics: nil, views: views)
    self.addConstraints(imageViewConstraintsVertical)

  }
  
}
