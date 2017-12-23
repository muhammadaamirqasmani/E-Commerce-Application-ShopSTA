//
//  ViewController.swift
//  SHOPSTA
//
//  Created by Techsviewer on 12/2/17.
//  Copyright © 2017 test. All rights reserved.
//

import UIKit
import Firebase


class MainVC: UIViewController {

    var quoteListener: ListenerRegistration!
    var appDelegte = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil{
            let uid = Auth.auth().currentUser?.uid
            
            quoteListener = Firestore.firestore().collection("user").whereField("uid", isEqualTo: uid).addSnapshotListener({  (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        self.appDelegte.UserProfleImage = document.data()["ImageURL"] as? String
                        self.appDelegte.UserName = document.data()["UserName"] as? String
                        print(self.appDelegte.UserName)
                        print(self.appDelegte.UserProfleImage)
                        self.performSegue(withIdentifier: "HomeVC", sender: self)
                    }
                }
            })
            
        }
    }


}

