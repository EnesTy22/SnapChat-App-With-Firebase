//
//  ViewController.swift
//  SnapChatFirebaseClone
//
//  Created by Enes Talha Yılmaz on 12.03.2023.
//

import UIKit
import Firebase
class SignInVC: UIViewController {

    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func SignInClicked(_ sender: Any) {
        if tfEmail.text != "" && tfPassword.text != ""{
            
            Auth.auth().signIn(withEmail: tfEmail.text!, password: tfPassword.text!) { auth, error in
                if error != nil {
                    self.PopAlert(alertTitle: "Error", messageTitle: error?.localizedDescription ?? "Unknown Error")
                }
                else{
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        }
        else{
            self.PopAlert(alertTitle: "Error", messageTitle: "Email or Password Cannot be Empty")
        }
    }
    
    @IBAction func SignUpClicked(_ sender: Any) {
        if tfEmail.text != "" && tfPassword.text != "" && tfUsername.text != ""{
            Auth.auth().createUser(withEmail: tfEmail.text!, password:tfPassword.text!) { auth, error in
                if error != nil{
                    self.PopAlert(alertTitle: "Error", messageTitle: error?.localizedDescription ?? "Unknown Error")
                }
                else{
                    let fireStore = Firestore.firestore()
                    let userDictionary = ["email" : self.tfEmail.text!,"username" : self.tfUsername.text!] as [String : Any]
                    fireStore.collection("UserInfo").addDocument(data: userDictionary) { error in
                        if error != nil
                        {
                            //
                        }
                        self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                    }
                }
            }
        

            }
        }
    func PopAlert(alertTitle : String, messageTitle : String){
        let alert = UIAlertController(title: alertTitle, message: messageTitle, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil)
        alert.addAction(okButton)
        self.present(alert,animated: true,completion: nil)
    }
}

