//
//  ViewController.swift
//  FilterBee
//
//  Created by Brian Ledbetter on 1/12/15.
//  Copyright (c) 2015 Brian Ledbetter. All rights reserved.
//

import UIKit
import Social

//MARK: ImageSelectedDelegate Protocol
protocol ImageSelectedDelegate{
  func DelegatorDidSelectImage(UIImage)->()
}
//MARK: Main ViewController
class ViewController: UIViewController, ImageSelectedDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  let alertController = UIAlertController(title: "FilterBee", message: "Choose a Photo to Filter", preferredStyle: UIAlertControllerStyle.ActionSheet)
  let photoButton = UIButton()
  var doneButton : UIBarButtonItem!
  var shareButton : UIBarButtonItem!
  
  var currentImage = UIImageView()
  var originalThumbnail : UIImage?
  var photoVerticalConstraint : NSArray!
  var photoHorizontalConstraint : NSArray!
  var photoBottomConstraint : NSLayoutConstraint!
  
  var filterNames = [String]()
  var collectionView : UICollectionView!
  var collectionViewYConstraint : NSLayoutConstraint?
  
  
  let imageQueue = NSOperationQueue()
  var gpuContext : CIContext!
  var thumbnails = [Thumbnail]()
  
  var views : [String : AnyObject]!
  
  var TwitterComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
  
  
//var doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "donePressed")
  
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
    
    self.views = ["photoButton" : photoButton]
    
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
    
    //setting up navbar buttons
    self.doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "donePressed")
    self.shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "sharePressed")
    
    // adding the autolayout bits
    self.setConstraintsOnRootView(rootView, forViews: views)
    
    // last step, setting our rootView
    self.view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // set up the button actions
    self.setUpMainButton()
    // a placeholder image  - set to BEEs
    if let placeholder = UIImage(named: "image1.jpeg"){
      currentImage.image = placeholder
    }
    
    // GPU mysterymeat
    let options = [kCIContextWorkingColorSpace : NSNull()]
    //    let EAGLContext = EAGLContext( EAGLRenderingAPI.OpenGLES2)
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    
    // create our set of filtered images
    self.setupThumbnails()
  }
  
  //MARK:Thumbnail Functions
  func setupThumbnails() {
    self.filterNames = ["CISepiaTone","CIPhotoEffectChrome", "CIPhotoEffectNoir", "CIColorMonochrome", "CIColorInvert", "CIFalseColor"]
    //generateThumbnail(currentImage.image!)
    for name in self.filterNames {
      let thumbnail = Thumbnail(incomingImage: currentImage.image!, filterName: name, operationQueue: self.imageQueue, context: self.gpuContext)
      self.thumbnails.append(thumbnail)
    }
  }
  
  func generateThumbnail(originalImage: UIImage) -> Void {
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
  
  //MARK:ImageSelectedDelegate Function
  func DelegatorDidSelectImage(selectedImage: UIImage) {
    self.currentImage.image = selectedImage
    self.thumbnails.removeAll(keepCapacity: false)
    self.collectionViewYConstraint?.constant = -120
    self.collectionView.reloadData()
    setupThumbnails()
  }
  
  //MARK: Button Actions
  func setUpMainButton(){
    let galleryOption = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      let galleryVC = GalleryViewController()
      self.navigationController?.pushViewController(galleryVC, animated: true)
      galleryVC.delegate = self
    }
    self.alertController.addAction(galleryOption)
    
    let filterOption = UIAlertAction(title: "Filter", style: .Default) { (action) -> Void in
      self.collectionViewYConstraint?.constant = 0.0
      //self.photoVerticalConstraint? = NSLayoutConstraint.constraintsWithVisualFormat("V:|-72-[currentImage(\(self.view.frame.height * 0.7))]-\(self.view.frame.height * 0.2)-|", options: nil, metrics: nil, views: self.views)
      self.photoBottomConstraint.constant = self.view.frame.height * 0.2
      UIView.animateWithDuration(0.8, animations: { () -> Void in
        self.view.layoutIfNeeded()
      })
    }
    self.alertController.addAction(filterOption)
    
    if UIImagePickerController.isSourceTypeAvailable(.Camera){
      let photoOption = UIAlertAction(title: "Photo", style: .Default) { (action) -> Void in
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .Camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
      }
      self.alertController.addAction(photoOption)
    }
    
    let photoAssetsOption = UIAlertAction(title: "Cloud", style: .Default) { (action) -> Void in
      let photoAssetVC = PhotoAssetsViewController()
      self.navigationController?.pushViewController(photoAssetVC, animated: true)
      photoAssetVC.delegate = self
    }
    self.alertController.addAction(photoAssetsOption)
  }
  
  func photoButtonPressed(sender : UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }
  
  func donePressed(){
    self.collectionViewYConstraint?.constant = -120
    self.photoBottomConstraint.constant = 30
    UIView.animateWithDuration(0.8, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
    self.navigationItem.rightBarButtonItem = self.shareButton
  }
  
  func sharePressed(){
    // share self.currentpic to Twitter
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
      self.TwitterComposeViewController.addImage(self.currentImage.image)
      self.presentViewController(self.TwitterComposeViewController, animated: true, completion: nil)
    }else{
      let alert = UIAlertController(title: "Twitter Log-in Required", message: "To post to Twitter, you must log in to Twitter on this device and allow this app access to your Twitter account in Settings.  This app will not gather information about you, nor post to Twitter without your permission.", preferredStyle: UIAlertControllerStyle.Alert)
      let okayAction = UIAlertAction(title: "Okay", style: .Cancel, handler: { (action) -> Void in
        
        self.dismissViewControllerAnimated(true, completion: nil)
      })
      self.presentViewController(alert, animated: true, completion: nil)
      alert.addAction(okayAction)
    }
  }
  
  //MARK: ImagePickerControllerDelegate
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    // set the image to main
    let imageFromCam = info[UIImagePickerControllerEditedImage] as? UIImage
    if imageFromCam != nil {
      self.DelegatorDidSelectImage(imageFromCam! as UIImage)
    }
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  //MARK: CollectionViewDataSource
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as GalleryViewCell
    let thumbnailAtRow = thumbnails[indexPath.row] as Thumbnail
    cell.imageView.image = thumbnailAtRow.filteredShrunkImage?
    return cell
  }
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.filterNames.count
  }
  //MARK: CollectionViewDelegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let thumbnailAtRow = thumbnails[indexPath.row] as Thumbnail
    thumbnailAtRow.filterImage(thumbnailAtRow.originalImage, isThumbnail: false)
    self.currentImage.image = thumbnailAtRow.filteredImage?
    collectionView.reloadData()
    self.navigationItem.rightBarButtonItem = self.doneButton

  }
  //MARK: AutoLayout Constraints
  func setConstraintsOnRootView(rootview: UIView, forViews views : [String : AnyObject]){

    // button constraints
    let photoButtonVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[photoButton]-20-|", options: nil, metrics: nil, views: views)
    rootview.addConstraints(photoButtonVerticalConstraint)
    let photoButtonConstraintHorizontal = NSLayoutConstraint(item: photoButton, attribute: .CenterX, relatedBy: .Equal, toItem: rootview, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
    rootview.addConstraint(photoButtonConstraintHorizontal)
    // photo constraints
    self.photoVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-72-[currentImage]-30-|", options: nil, metrics: nil, views: views)
    self.photoBottomConstraint = photoVerticalConstraint[1] as NSLayoutConstraint
    rootview.addConstraints(photoVerticalConstraint!)
    self.photoHorizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("|[currentImage]|", options: nil, metrics: nil, views: views)
    rootview.addConstraints(photoHorizontalConstraint!)
    // setting currentImage constraints
    currentImage.backgroundColor = UIColor.darkGrayColor()
    currentImage.contentMode = UIViewContentMode.ScaleAspectFill
    currentImage.layer.masksToBounds = true
    currentImage.layer.cornerRadius = 24.0
    // collectionView constraints
    collectionView.backgroundColor = UIColor.lightGrayColor()
    let collectionViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: nil, metrics: nil, views: views)
    rootview.addConstraints(collectionViewConstraintsHorizontal)
    let collectionViewHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(\(rootview.frame.height * 0.2))]", options: nil, metrics: nil, views: views)
    collectionView.addConstraints(collectionViewHeight)
    let collectionViewVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView]-(-120)-|", options: nil, metrics: nil, views: views)
    rootview.addConstraints(collectionViewVerticalConstraint)
    self.collectionViewYConstraint = collectionViewVerticalConstraint.first as? NSLayoutConstraint
  }
}

