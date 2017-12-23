//
//  HomeVC.swift
//  SHOPSTA
//
//  Created by admin on 02/12/2017.
//  Copyright © 2017 test. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import ObjectMapper
import SDWebImage



class HomeVC: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    @IBOutlet weak var pictureCollection: UICollectionView!
    @IBOutlet weak var UserProfileImage: UIImageView!
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var FollowersCount: UILabel!
    
    
    var quoteListener: ListenerRegistration!
    var picturearray = [pictureObject]()
    let userID = Auth.auth().currentUser!.uid
    let userName = Auth.auth().currentUser?.displayName
    var imagePicker = UIImagePickerController()
    let db = Firestore.firestore()
    var data = NSData()
    var appDelegte = UIApplication.shared.delegate as! AppDelegate
    var docRef : DocumentReference? = nil
    let currentUser = Auth.auth().currentUser!
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pictureCollection.delegate = self
        pictureCollection.dataSource = self
        self.addSlideMenuButton()
        self.title = "Home"
        self.UserName.text = self.appDelegte.UserName
        self.UserProfileImage.sd_setImage(with: URL(string: self.appDelegte.UserProfleImage!), placeholderImage: UIImage(named: "placeholder.png"))
        
        activityView.center = self.view.center
        
        UserProfileImage.layer.borderWidth = 1
        UserProfileImage.layer.masksToBounds = false
        UserProfileImage.layer.borderColor = UIColor.yellow.cgColor
        UserProfileImage.layer.cornerRadius = UserProfileImage.frame.height/2
        UserProfileImage.clipsToBounds = true
        
        activityView.startAnimating()
        quoteListener = Firestore.firestore().collection("shopstaImages").addSnapshotListener({  (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let array = querySnapshot!.documents.map({ (data) -> pictureObject in
                    let obj = Mapper<pictureObject>().map(JSON: data.data())!
                    obj.id = data.documentID
                    print(obj.UserName)
                    return obj
                })
                print(array)
                pictureObject.pictureDetail = array
                self.picturearray = array
                self.pictureCollection.reloadData()
                self.activityView.stopAnimating()
            }
        })
    }
    
    
    
    func uploadImageTOFirebaseStorage(data: NSData){
        let storage = Storage.storage().reference(withPath: "user/userShopstaNode/\(Date().timeIntervalSince1970).jpeg")
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        let uploadTask = storage.putData(data as Data, metadata: uploadMetaData) { (metadata, error) in
            if (error != nil){
                print("I received an error! \(String(describing: error?.localizedDescription))")
            }else {
                let downloadURL = metadata?.downloadURL()?.absoluteString
                let when = DispatchTime.now() + 3 // change 2 to desired number of seconds
                DispatchQueue.main.asyncAfter(deadline: when) {
                    // Your code with delay
                    self.getDataFromController(UserName: self.appDelegte.UserName!, uid: self.userID, ImageURL: downloadURL!, timeStamp: Date().toTimestamp)
                }
            }
        }
    }
    
    
    func getDataFromController (UserName: String,  uid: String, ImageURL: String, timeStamp: Double ){
        let docData: [String: Any] = ["UserName": UserName, "uid": uid, "ImageURL": ImageURL, "timeStamp": timeStamp]
        docRef = db.collection("shopstaImages").addDocument(data: docData){ err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.docRef!.documentID)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picturearray.count
    
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCollectionVC
        
        cell.ItemImage.sd_setImage(with: URL(string: picturearray[indexPath.row].ImageURL!), placeholderImage: UIImage(named: "placeholder.png"))
        return cell
        
    }
    
    @IBAction func ItemPicture(_ sender: Any) {
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate=self
        
        let actionController = UIAlertController(title: "Profile Image", message: "Please select profile image for Distill", preferredStyle: .actionSheet)
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        actionController.addAction(galleryAction)
        actionController.addAction(cancel)
        actionController.addAction(cameraAction)
        self.present(actionController, animated: true, completion: nil)
    }
    
    
}
extension HomeVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //        self.ItemImage.image = image
        self.data = UIImageJPEGRepresentation(image, 0.8)! as NSData
        self.uploadImageTOFirebaseStorage(data: self.data)
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension Date{
    var toTimestamp:Double{
        return self.timeIntervalSince1970 * 1000
    }
    static func <(lhs:Date,rhs:Date)->Bool{
        return lhs.compare(rhs) == ComparisonResult.orderedDescending
    }
    static func >(lhs:Date,rhs:Date)->Bool{
        return lhs.compare(rhs) == ComparisonResult.orderedAscending
    }
    //    var toMessageDate:String{
    //        let m = moment(self)
    //        return m.format("hh:mm a")
    //    }
}
extension Double{
    var toDate:Date{
        return Date(timeIntervalSince1970: self / 1000)
    }
    
}
