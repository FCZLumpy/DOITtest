//
//  CreateImage.swift
//  DOITtest
//
//  Created by LumpyElzas on 21.03.17.
//  Copyright © 2017 LumpyElzas. All rights reserved.
//

import UIKit
import Photos

class CreateImage: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tfDescription: UITextField!
    @IBOutlet weak var tfHashtag: UITextField!
    
    var isImageChanged = false
    var latitude = 0.0
    var longtitude = 0.0
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(CreateImage.tapDetected))
        singleTap.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
        
        //ar locationManager: CLLocationManager = C
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tapDetected() {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: { _ in })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        longtitude = userLocation.coordinate.longitude;
        latitude = userLocation.coordinate.latitude;
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleToFill
            imageView.image = pickedImage
            isImageChanged = true
        }
        
        let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        self.imageFromAsset(nsurl: imageURL)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imageFromAsset(nsurl: NSURL) {
        let asset = PHAsset.fetchAssets(withALAssetURLs: [nsurl as URL], options: nil).firstObject
        if let location = asset?.location {
            latitude = location.coordinate.latitude
            longtitude = location.coordinate.longitude
        }
    }

    @IBAction func btnSendClick(_ sender: UIButton) {
        if(isImageChanged) {
            let img = imageView.image
            
            Networking.sharedInstance.sendImage(description: tfDescription.text!, hashtag: tfHashtag.text!, latitude: String(latitude), longitude: String(longtitude))
            Networking.sharedInstance.sendToServerWithPhotoAndCoordinates(image: img!, callback: { [unowned self] (result, error)   in
                if(error == 0) {
                    self.isImageChanged = false
                }
            })
        } else {
            let alertController = UIAlertController(title: "Error", message: "Change image", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
