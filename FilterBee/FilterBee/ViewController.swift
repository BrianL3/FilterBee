//
//  ViewController.swift
//  FilterBee
//
//  Created by Brian Ledbetter on 1/12/15.
//  Copyright (c) 2015 Brian Ledbetter. All rights reserved.
//

import UIKit

//MARK: ImageSelectedDelegate Protocol
protocol ImageSelectedDelegate{
  func DelegatorDidSelectImage(UIImage)->()
}
//MARK: Main ViewController
class ViewController: UIViewController, ImageSelectedDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
  
  let alertController = UIAlertController(title: "FilterBee", message: "Choose a Photo to Filter", preferredStyle: UIAlertControllerStyle.ActionSheet)
  let photoButton = UIButton()
  var currentImage = UIImageView()
  var filterNames = [String]()
  var collectionView : UICollectionView!
  var collectionViewYConstraint : NSLayoutConstraint?
  let imageQueue = NSOperationQueue()
  var gpuContext : CIContext!
  var thumbnails = [Thumbnail]()
  var originalThumbnail : UIImage?

  
  //MARK: ViewController Life Cycle
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.grayColor()
    
    // setting up the photobutton
    photoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    photoButton.setTitle("Start", forState: .Normal)
    photoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    photoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    rootView.addSubview(photoButton)
    var views : [String : AnyObject] = ["photoButton" : photoButton]
    
    // setting up the primary image
    currentImage.setTranslatesAutoresizingMaskIntoConstraints(false)
    views.updateValue(currentImage, forKey: "currentImage")
    rootView.addSubview(currentImage)
    rootView.sendSubviewToBack(currentImage)
    
    // setting up our collectionView
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewFlowLayout)
    collectionViewFlowLayout.itemSize = CGSize(width: 100, height: 100)
    collectionViewFlowLayout.scrollDirection = .Horizontal
    views.updateValue(collectionView, forKey: "collectionView")
    self.collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(collectionView)
    
    // setting collectionView datasource and delegate as ourself
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(GalleryViewCell.self, forCellWithReuseIdentifier: "FILTER_CELL")
    
    // adding the autolayout bits
    self.setConstraintsOnRootView(rootView, forViews: views)
    
    // last step, setting our rootView
    self.view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // set up the button actions
    let galleryOption = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      let galleryVC = GalleryViewController()
      self.navigationController?.pushViewController(galleryVC, animated: true)
      galleryVC.delegate = self
    }
    self.alertController.addAction(galleryOption)
    let filterOption = UIAlertAction(title: "Filter", style: .Default) { (action) -> Void in
      self.collectionViewYConstraint?.constant = 45
      UIView.animateWithDuration(0.8, animations: { () -> Void in
        self.view.setNeedsLayout()
      })
    }
    self.alertController.addAction(filterOption)
    
    // a placeholder image  - set to BEEs
    if let placeholder = UIImage(named: "image1.jpeg"){
      currentImage.image = placeholder
    }
    
    // GPU mysterymeat
    let options = [kCIContextWorkingColorSpace : NSNull()]
    //    let EAGLContext = EAGLContext( EAGLRenderingAPI.OpenGLES2)
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    self.setupThumbnails()

  }
  
  //MARK:Thumbnail Functions
  func setupThumbnails() {
    self.filterNames = ["CISepiaTone","CIPhotoEffectChrome", "CIPhotoEffectNoir", "CIColorMonochrome", "CIColorInvert", "CIFalseColor"]
    generateThumbnail(currentImage.image!)
    for name in self.filterNames {
      let thumbnail = Thumbnail(incomingImage: originalThumbnail!, filterName: name, operationQueue: self.imageQueue, context: self.gpuContext)
      self.thumbnails.append(thumbnail)
    }
  }
  
  func generateThumbnail(originalImage: UIImage) -> Void {
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
  }
  
  //MARK:ImageSelectedDelegate Function
  func DelegatorDidSelectImage(selectedImage: UIImage) {
    self.currentImage.image = selectedImage
    self.thumbnails.removeAll(keepCapacity: false)
    self.collectionViewYConstraint?.constant = -120
    UIView.animateWithDuration(0.8, animations: { () -> Void in
      self.view.setNeedsLayout()
    })
    self.collectionView.reloadData()
    setupThumbnails()
  }
  
  //MARK: Button Actions
  func photoButtonPressed(sender : UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }
  
  //MARK: CollectionViewDataSource
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as GalleryViewCell
    let thumbnailAtRow = thumbnails[indexPath.row] as Thumbnail
    cell.imageView.image = thumbnailAtRow.filteredImage?
    return cell
  }
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.filterNames.count
  }
  //MARK: CollectionViewDelegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let thumbnailAtRow = thumbnails[indexPath.row] as Thumbnail
    self.currentImage.image = thumbnailAtRow.filteredImage
    collectionView.reloadData()
  }
  //MARK: AutoLayout Constraints
  func setConstraintsOnRootView(rootview: UIView, forViews views : [String : AnyObject]){

    // button constraints
    let photoButtonVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[photoButton]-20-|", options: nil, metrics: nil, views: views)
    rootview.addConstraints(photoButtonVerticalConstraint)
    let photoButtonConstraintHorizontal = NSLayoutConstraint(item: photoButton, attribute: .CenterX, relatedBy: .Equal, toItem: rootview, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
    rootview.addConstraint(photoButtonConstraintHorizontal)
    // photo constraints
    let photoVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-72-[currentImage]-30-|", options: nil, metrics: nil, views: views)
    rootview.addConstraints(photoVerticalConstraint)
    let photoHorizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("|[currentImage]|", options: nil, metrics: nil, views: views)
    rootview.addConstraints(photoHorizontalConstraint)
    // setting currentImage constraints
    currentImage.backgroundColor = UIColor.darkGrayColor()
    currentImage.contentMode = UIViewContentMode.ScaleAspectFill
    currentImage.layer.masksToBounds = true
    currentImage.layer.cornerRadius = 24.0
    // collectionView constraints
    collectionView.backgroundColor = UIColor.lightGrayColor()
    let collectionViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: nil, metrics: nil, views: views)
    rootview.addConstraints(collectionViewConstraintsHorizontal)
    //let collectionViewHeight = NSLayoutConstraint(item: self.collectionView, attribute: .Height, relatedBy: .Equal, toItem: currentImage, attribute: .Height, multiplier: 0.2, constant: 0.0)
     //collectionView.addConstraint(collectionViewHeight)
    let collectionViewHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(\(rootview.frame.height * 0.2))]", options: nil, metrics: nil, views: views)
    collectionView.addConstraints(collectionViewHeight)
    let collectionViewVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView]-(-120)-|", options: nil, metrics: nil, views: views)
    rootview.addConstraints(collectionViewVerticalConstraint)
    self.collectionViewYConstraint = collectionViewVerticalConstraint.first as? NSLayoutConstraint
  }
}

