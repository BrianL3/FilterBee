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
    self.backgroundColor = UIColor.whiteColor()
    imageView.frame = self.bounds
    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 16.0
    imageView.backgroundColor = UIColor.lightGrayColor()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
