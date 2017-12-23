//
//  LoginVC.swift
//  SHOPSTA
//
//  Created by admin on 02/12/2017.
//  Copyright © 2017 test. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var UserEmail: UnderlinedTextField!
    @IBOutlet weak var UserPassword: UnderlinedTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func LogIn(_ sender: Any) {
        
        guard let email = UserEmail.text else {return}
        guard let pass = UserPassword.text else {return}
        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            if error ==  nil && user != nil{
                print("user Created")
                self.UserEmail.text = ""
                self.UserPassword.text = ""
                self.dismiss(animated: true, completion: nil)
            }else {
                print("Error is \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @IBAction func BackBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
