//
//  Thumbnail.swift
//  FilterBee
//
//  Created by Brian Ledbetter on 1/13/15.
//  Copyright (c) 2015 Brian Ledbetter. All rights reserved.
//

import UIKit

class Thumbnail {
  var originalImage : UIImage!
  var originalOrientation : UIImageOrientation!
  var shrunkImage : UIImage?
  var filteredImage : UIImage?
  var filteredShrunkImage : UIImage?
  var filterName : String!
  var imageQueue : NSOperationQueue!
  var gpuContext : CIContext!
  
  init(incomingImage : UIImage, filterName: String, operationQueue : NSOperationQueue, context : CIContext){
    self.originalImage = incomingImage
    self.originalOrientation = incomingImage.imageOrientation
    self.filterName = filterName
    self.imageQueue = operationQueue
    self.gpuContext = context
    shrinkImage(self.originalImage)
    filterImage(self.shrunkImage!, isThumbnail: true)
  }
  
  func filterImage(imageToFilter: UIImage, isThumbnail: Bool) {
    let start = CIImage(image: imageToFilter)
    let filter = CIFilter(name: self.filterName)
    filter.setDefaults()
    filter.setValue(start, forKey: kCIInputImageKey)
    let imageInProcess = filter.valueForKey(kCIOutputImageKey) as CIImage
    let extent = imageInProcess.extent()
    let end = self.gpuContext.createCGImage(imageInProcess, fromRect: extent)
    if isThumbnail{
      self.filteredShrunkImage = UIImage(CGImage: end)
    }else{
      self.filteredImage = UIImage(CGImage: end, scale: 1.0, orientation: self.originalOrientation)
    }
  }
  
  func shrinkImage(originalImage: UIImage) -> Void {
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    self.shrunkImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
}
