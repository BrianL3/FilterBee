//
//  ViewController.swift
//  FilterBee
//
//  Created by Brian Ledbetter on 1/12/15.
//  Copyright (c) 2015 Brian Ledbetter. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  let alertController = UIAlertController(title: "FilterBee", message: "Choose a Photo to Filter", preferredStyle: UIAlertControllerStyle.ActionSheet)
  let photoButton = UIButton()
  var currentImage = UIImageView()
  
//MARK: ViewController Life Cycle
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.grayColor()
    // setting up the photobutton
    photoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    photoButton.setTitle("Gallery", forState: .Normal)
    photoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    photoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    rootView.addSubview(photoButton)
    var views : [String : AnyObject] = ["photoButton" : photoButton]
    // setting up the primary image
    currentImage.setTranslatesAutoresizingMaskIntoConstraints(false)
    views.updateValue(currentImage, forKey: "currentImage")
    rootView.addSubview(currentImage)
    rootView.sendSubviewToBack(currentImage)
//    views.updateValue("currentImage", forKey: currentImage)
    // adding the autolayout bits
    self.setConstraintsOnRootView(rootView, forViews: views)
    currentImage.backgroundColor = UIColor.darkGrayColor()
    currentImage.layer.masksToBounds = true
    currentImage.layer.cornerRadius = 24.0
    self.view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let galleryOption = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      let galleryVC = GalleryViewController()
      self.navigationController?.pushViewController(galleryVC, animated: true)
    }
    self.alertController.addAction(galleryOption)
    if let placeholder = UIImage(named: "image1.jpeg"){
     currentImage.image = placeholder
    }
  }
//MARK: Button Actions
  func photoButtonPressed(sender : UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }

//MARK: AutoLayout Constraints
  func setConstraintsOnRootView(rootview: UIView, forViews views : [String : AnyObject]){
    // button constraints
    let photoButtonVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[photoButton]-20-|", options: nil, metrics: nil, views: views)
    rootview.addConstraints(photoButtonVerticalConstraint)
    let photoButtonConstraintHorizontal = NSLayoutConstraint(item: photoButton, attribute: .CenterX, relatedBy: .Equal, toItem: rootview, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
    rootview.addConstraint(photoButtonConstraintHorizontal)
    // photo constraints
    let photoVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-60-[currentImage]-40-|", options: nil, metrics: nil, views: views)
    rootview.addConstraints(photoVerticalConstraint)
    let photoHorizontalConstraint = NSLayoutConstraint(item: currentImage, attribute: .CenterX, relatedBy: .Equal, toItem: rootview, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
    rootview.addConstraint(photoHorizontalConstraint)
  }
}

