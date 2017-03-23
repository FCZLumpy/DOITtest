//
//  Networking.swift
//  DOITtest
//
//  Created by LumpyElzas on 21.03.17.
//  Copyright © 2017 LumpyElzas. All rights reserved.
//

import Foundation
import Alamofire

class Networking {
    static let sharedInstance = Networking()
    var parameters: Parameters = ["":""]
    
    func registration(avatar : UIImage, email: String, password: String, name: String = "")
    {
        parameters = [
                    "email": email,
                    "password": password,
                    "username": name
                    
            ]
    }
    
    func logIn(email: String, password: String)
    {
        parameters = [
            "email": email,
            "password": password
        ]
    }
    
    func sendImage(description : String, hashtag: String, latitude: String, longitude: String)
    {
        parameters = [
            "description": description,
            "hashtag": hashtag,
            "latitude": latitude,
            "longitude": longitude
        ]
    }
    
    func sendToServer(callback:@escaping (Dictionary <String, AnyObject>, Int)  -> Void)
    {
        Alamofire.request("http://api.doitserver.in.ua/login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                if let data = response.result.value {
                    callback(data as! Dictionary<String, AnyObject>, 0)
                }
                break
                
            case .failure(_):
                print(response.result.error as Any)
                break
            }
        }
    }
    
    func sendToServerGet(url: String, callback:@escaping (Dictionary <String, AnyObject>, Int)  -> Void)
    {
        let header: HTTPHeaders = ["token": UserData.sharedInstance.userToken]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    callback(data as! Dictionary<String, AnyObject>, 0)
                }
                break
                
            case .failure(_):
                print(response.result.error ?? "")
                break
                
            }
        }
    }
    
    func sendToServerWithPhoto(image: UIImage, callback:@escaping (Dictionary <String, AnyObject>, Int)  -> Void)
    {
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImageJPEGRepresentation(image, 0.5)!, withName: "avatar", fileName: "image", mimeType: "image/jpeg")
            for (key, value) in self.parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, to:"http://api.doitserver.in.ua/create")
        { (result) in
            
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print(progress)
                })
                
                upload.responseJSON { response in
                    //print response.result
                    callback(response.result.value as! Dictionary<String, AnyObject>, 0)
                }
                
            case .failure(let encodingError): break
                //print encodingError.description
            }
        }
    }
    
    func sendToServerWithPhotoAndCoordinates(image: UIImage, callback:@escaping (Dictionary <String, AnyObject>, Int)  -> Void)
    {
        let header: HTTPHeaders = ["token": UserData.sharedInstance.userToken]
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(UIImageJPEGRepresentation(image, 0.5)!, withName: "image", fileName: "image", mimeType: "image/jpeg")
            multipartFormData.append((self.parameters["description"] as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: "description")
            multipartFormData.append((self.parameters["hashtag"] as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: "hashtag")
            multipartFormData.append((self.parameters["latitude"] as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: "latitude")
            multipartFormData.append((self.parameters["longitude"] as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: "longitude")
            
        }, to:"http://api.doitserver.in.ua/image", headers: header)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print(progress)
                })
                
                upload.responseJSON { response in
                    //print response.result
                    callback(response.result.value as! Dictionary<String, AnyObject>, 0)
                }
            case .failure(let encodingError): break
                //print encodingError.description
            }
        }
    }


}
