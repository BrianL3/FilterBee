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
  var filteredImage : UIImage?
  var filterName : String!
  var imageQueue : NSOperationQueue!
  var gpuContext : CIContext!
  
  init(incomingImage : UIImage, filterName: String, operationQueue : NSOperationQueue, context : CIContext){
    self.originalImage = incomingImage
    self.filterName = filterName
    self.imageQueue = operationQueue
    self.gpuContext = context
    filterImage()
  }
  
  func filterImage() {
    let start = CIImage(image: self.originalImage)
    let filter = CIFilter(name: self.filterName)
    filter.setDefaults()
    filter.setValue(start, forKey: kCIInputImageKey)
    let imageInProcess = filter.valueForKey(kCIOutputImageKey) as CIImage
    let extent = imageInProcess.extent()
    let end = self.gpuContext.createCGImage(imageInProcess, fromRect: extent)
    self.filteredImage = UIImage(CGImage: end)
  }
}
