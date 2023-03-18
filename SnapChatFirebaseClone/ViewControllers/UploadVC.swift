//
//  UploadVC.swift
//  SnapChatFirebaseClone
//
//  Created by Enes Talha Yılmaz on 12.03.2023.
//

import UIKit
import Firebase
import FirebaseStorage

class UploadVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var ivUpload: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ivUpload.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePicture))
        ivUpload.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view.
    }
    
    @objc func choosePicture()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker,animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        ivUpload.image=info[.originalImage] as? UIImage
        self.dismiss(animated: true,completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func UploadImageClicked(_ sender: Any) {
        //Storage
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("media")
        if let data = ivUpload.image?.jpegData(compressionQuality: 0.5)
        {
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data,metadata: nil) { metaData, error in
                if error != nil
                {
                    self.PopAlert(alertTitle: "Error", messageTitle: error?.localizedDescription ?? "Unknown Error")

                }
                else{
                    imageReference.downloadURL { url, error in
                        if error == nil{
                            let imageUrl = url?.absoluteString
                            
                            //Firestore
                            
                            let fireStore = Firestore.firestore()
                            
                            fireStore.collection("Snaps").whereField("snapOwner", isEqualTo: UserSingleton.sharedUserInfo.username).getDocuments { snapShot, error in
                                if error != nil
                                {
                                    self.PopAlert(alertTitle: "Error", messageTitle: error?.localizedDescription ?? "Unknown Error")
                                }
                                else{
                                    if snapShot?.isEmpty == false && snapShot != nil{
                                        for document in snapShot!.documents
                                        {
                                            let documentId = document.documentID
                                            if var imageUrlArray = document.get("imageUrlArray") as? [String]
                                            {
                                                imageUrlArray.append(imageUrl!)
                                                let updatedDictionary = ["imageUrlArray" : imageUrlArray] as [String : Any]
                                                fireStore.collection("Snaps").document(documentId).setData( updatedDictionary, merge: true) { error in
                                                    if error != nil
                                                    {
                                                        self.PopAlert(alertTitle: "Error", messageTitle: error?.localizedDescription ?? "Unknown Error")
                                                    }
                                                    else{
                                                        self.tabBarController?.selectedIndex = 0
                                                        self.ivUpload.image = UIImage(systemName: "photo.artframe")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        let snapDictionary = ["imageUrlArray" : [imageUrl!],"snapOwner" : UserSingleton.sharedUserInfo.username,"date" : FieldValue.serverTimestamp()] as [String : Any]
                                        
                                        fireStore.collection("Snaps").addDocument(data: snapDictionary) { error in
                                            if error != nil
                                            {
                                                self.PopAlert(alertTitle: "Error", messageTitle: error?.localizedDescription ?? "Error")
                                                 
                                            }
                                            else{
                                                self.tabBarController?.selectedIndex = 0
                                                self.ivUpload.image = UIImage(systemName: "photo.artframe")
                                            }
                                    }
                                }
                            }
                            
                            }
                        }
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
