//
//  SignUpVC.swift
//  SHOPSTA
//
//  Created by admin on 02/12/2017.
//  Copyright © 2017 test. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class SignUpVC: UIViewController {

   
    @IBOutlet weak var UserName: UnderlinedTextField!
    @IBOutlet weak var UserEmail: UnderlinedTextField!
    @IBOutlet weak var UserRePassword: UnderlinedTextField!
    @IBOutlet weak var UserPassword: UnderlinedTextField!
    @IBOutlet weak var ProfileImage: UIImageView!
    
    
    var imagePicker = UIImagePickerController()
    var data = NSData()
    var docRef : DocumentReference? = nil
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ProfileImage.layer.borderWidth = 1
        ProfileImage.layer.masksToBounds = false
        ProfileImage.layer.borderColor = UIColor.green.cgColor
        ProfileImage.layer.cornerRadius = ProfileImage.frame.height/2
        ProfileImage.clipsToBounds = true
    }
    
    
    func uploadImageTOFirebaseStorage(data: NSData){
        let storage = Storage.storage().reference(withPath: "user/userImage/\(String(describing: UserEmail.text)).jpeg")
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
                    guard let UserName = self.UserName.text else {return}
                    guard let UserEmail = self.UserEmail.text else {return}
                    guard let UserPassword = self.UserPassword.text else {return}
                    let userID = Auth.auth().currentUser!.uid
                    self.getDataFromController(UserName: UserName, UserEmail: UserEmail, UserPassword: UserPassword, uid:userID, ImageURL: downloadURL!)
                    self.UserEmail.text = ""
                    self.UserPassword.text = ""
                    self.UserRePassword.text = ""
                    self.UserName.text = ""
                }
            }
        }
    }
    
    func getDataFromController (UserName: String, UserEmail: String, UserPassword: String, uid: String, ImageURL: String ){
        let docData: [String: Any] = ["UserName": UserName, "UserEmail": UserEmail, "UserPassword": UserPassword, "uid": uid, "ImageURL": ImageURL]
        docRef = db.collection("user").addDocument(data: docData){ err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.docRef!.documentID)")
            }
        }
    }
    
    @IBAction func SignUpFirebase(_ sender: Any) {
        
        guard let email = UserEmail.text else {return}
        guard let pass = UserPassword.text else {return}
        guard let repass = UserRePassword.text else {return}
        
        if pass == repass {
            Auth.auth().createUser(withEmail: email, password: pass) { (user, error) in
                if error ==  nil && user != nil{
                    print("user Created")
                    self.uploadImageTOFirebaseStorage(data: self.data)
                    
                    
                    self.dismiss(animated: true, completion: nil)
                }else {
                    print("Error is \(String(describing: error?.localizedDescription))")
                }
            }
            
        } else {
            let alertController =    UIAlertController(title: "Incorrect Password", message: "Check Your Password", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction!) in
                print("you have pressed OK button");
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)
        }
    }
    
    
    @IBAction func BackbBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func ChooseUserImage(_ sender: Any) {
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
extension SignUpVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.ProfileImage.image = image
        self.data = UIImageJPEGRepresentation(image, 0.8)! as NSData
        self.dismiss(animated: true, completion: nil)
    }
}
