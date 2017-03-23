//
//  Registration.swift
//  DOITtest
//
//  Created by LumpyElzas on 21.03.17.
//  Copyright © 2017 LumpyElzas. All rights reserved.
//

import UIKit

class Registration: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEMail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
       
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Registration.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(CreateImage.tapDetected))
        singleTap.numberOfTapsRequired = 1
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(singleTap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tapDetected() {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: { _ in })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avatarImageView.contentMode = .scaleToFill
            avatarImageView.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSendClick(_ sender: UIButton) {
        let img = avatarImageView.image
        
        Networking.sharedInstance.registration(avatar: img!, email: tfEMail.text!, password: tfPassword.text!)
        Networking.sharedInstance.sendToServerWithPhoto(image: img!,  callback: { [unowned self] (result, error)   in
            if(error == 0)
            {
                if let data = result["token"] {
                    UserData.sharedInstance.userToken = data as! String
                    print(UserData.sharedInstance.userToken)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
                    self.navigationController?.pushViewController(vc!, animated: false)
                } else {
                   let data = result["children"] as! Dictionary<String, AnyObject>
                        if data["email"] != nil {
                                self.checkPassword()
                        }
                    }
            }
        })
    }
    
    func checkPassword()
    {
        Networking.sharedInstance.logIn(email: tfEMail.text!, password: tfPassword.text!)
        Networking.sharedInstance.sendToServer(callback: { [unowned self] (result, error)   in
            if(error == 0) {
                if let data = result["token"] {
                    UserData.sharedInstance.userToken = data as! String
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
                    self.navigationController?.pushViewController(vc!, animated: false)
                }
            } else {
                print("some error")
            }
        })
    }
    
}
