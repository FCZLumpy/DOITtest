//
//  ViewController.swift
//  DOITtest
//
//  Created by LumpyElzas on 21.03.17.
//  Copyright © 2017 LumpyElzas. All rights reserved.
//

import UIKit

struct ImageModel {
    let bigImagePath: String
    let created: String
    let description: String
    let hashtag: String
    let id: Int
    let parameters: [String: AnyObject]
    var smallImagePath: String
}

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var tfName: UILabel!
    @IBOutlet weak var tfWeather: UILabel!
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gifView: UIView!
    
    var imageArray: [ImageModel] = []
    let cellIdentifier = "ImageCollectionViewCell"
    let cache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(CreateImage.tapDetected))
        singleTap.numberOfTapsRequired = 1
        gifView.isUserInteractionEnabled = true
        gifView.addGestureRecognizer(singleTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gifView.isHidden = true
       
        Networking.sharedInstance.sendToServerGet(url: "http://api.doitserver.in.ua/all", callback: { [unowned self] (result, error)   in
            if(error == 0)
            {
                if let data = result["images"]
                {
                    self.imageArray = []
                    for image in data as! Array<Dictionary<String, AnyObject>>
                    {
                        var description = ""
                        if image["description"] as? String != nil {
                            description = image["description"] as! String
                        }
                        
                        var hashtag = ""
                        if image["hashtag"] as? String != nil {
                            hashtag = image["hashtag"] as! String
                        }
                        
                        let imageModel = ImageModel(bigImagePath: image["bigImagePath"] as! String, created: "", description: description, hashtag: hashtag, id: image["id"] as! Int, parameters: image["parameters"] as! [String : AnyObject], smallImagePath: image["smallImagePath"] as! String)
                        
                        self.imageArray.append(imageModel)
                    }
                }
                
                self.collectionView.reloadData()
            }
        })
    }
    func tapDetected() {
        gifView.isHidden = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath) as! ImageCollectionViewCell
    
        cell.tfName.text = imageArray[indexPath.row].description
        cell.tfWeather.text = (imageArray[indexPath.row].parameters["weather"] as! String)
        let str = imageArray[indexPath.row].smallImagePath
        DispatchQueue.main.async( execute: {
            if str != ""
            {
                let url = NSURL(string: str)
                if let data = self.cache.object(forKey: url!) {
                    let image = data
                    cell.image.image = image as? UIImage;
                } else {
                    if let data = NSData(contentsOf: url! as URL) {
                        let tmpImg = UIImage(data: data as Data)
                        cell.image.image = tmpImg
                        self.cache.setObject(tmpImg!, forKey: url!)
                    }
                }
            }
        })
        
        return cell
    }
 
    @IBAction func btnAddImageClick(_ sender: UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateImage")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func btnDoGifClick(_ sender: UIButton) {
        Networking.sharedInstance.sendToServerGet(url: "http://api.doitserver.in.ua/gif", callback: { [unowned self] (result, error)   in
            if(error == 0) {
                self.gifView.isHidden = false
                if let gifURL : String = result["gif"] as! String? {
                    
                    let imageURL = UIImage.gifImageWithURL(gifUrl: gifURL)
                    let imageView = UIImageView(image: imageURL)
                    imageView.frame = CGRect(x: 20.0, y: 140.0, width: self.view.frame.size.width - 40, height: 150.0)
                    self.gifView.addSubview(imageView)
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

