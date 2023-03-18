//
//  FeedVC.swift
//  SnapChatFirebaseClone
//
//  Created by Enes Talha Yılmaz on 12.03.2023.
//

import UIKit
import Firebase
import SDWebImage
class FeedVC: UIViewController,UITableViewDataSource,UITableViewDelegate {

    let fireStoreDB = Firestore.firestore()
    @IBOutlet weak var tvFeed: UITableView!
    var snapArray = [Snap]()
    var chosenSnap : Snap?
    override func viewDidLoad() {
        super.viewDidLoad()
        tvFeed.delegate=self
        tvFeed.dataSource=self
        // Do any additional setup after loading the view.
        getUserInfo()
        GetSnapsFromFirebase()
    }
    func getUserInfo()
    {
        fireStoreDB.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { snapshot, error in
            if error != nil
            {
                self.PopAlert(alertTitle: "Error", messageTitle: error?.localizedDescription ?? "Unknown Error")
            }
            else
            {
                if snapshot?.isEmpty == false && snapshot != nil
                {
                    for document in snapshot!.documents
                    {
                        if let name = document.get("username") as? String
                        {
                            UserSingleton.sharedUserInfo.email = Auth.auth().currentUser!.email!
                            UserSingleton.sharedUserInfo.username = name
                        }
                    }
                }
            }
        }
    }
    func GetSnapsFromFirebase()
    {
        fireStoreDB.collection("Snaps").order(by: "date", descending: true).addSnapshotListener { snapshot, error in
            if error != nil
            {
                self.PopAlert(alertTitle: "error", messageTitle: error?.localizedDescription ?? "Error!")
            }
            else
            {
                if snapshot?.isEmpty == false && snapshot != nil
                {
                    self.snapArray.removeAll()
                    for document in snapshot!.documents {
                        let documentId = document.documentID
                        if let username = document.get("snapOwner") as? String{
                            if let imageUrlArray = document.get("imageUrlArray") as? [String]{
                                if let date = document.get("date") as? Timestamp
                                {
                                    if let difference = Calendar.current.dateComponents([.hour], from: date.dateValue(), to: Date()).hour{
                                        if difference >= 24{
                                            //Delete
                                            self.fireStoreDB.collection("Snaps").document(documentId).delete { error in
                                                
                                            }
                                            
                                        }
                                        else
                                        {
                                            let snap = Snap(userName: username, imageUrlArray: imageUrlArray, date: date.dateValue(),TimeDifference: 24-difference)
                                            self.snapArray.append(snap)
                                        }
                                        
                                      
                                    }
                                   
                                }}

                        }
                        
                    }
                    self.tvFeed.reloadData()
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
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tvFeed.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.lblFeedUsername.text = snapArray[indexPath.row].userName
        cell.ivFeed.sd_setImage(with: URL(string: snapArray[indexPath.row].imageUrlArray[0]))
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenSnap = self.snapArray[indexPath.row]
        performSegue(withIdentifier: "toSnapVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSnapVC"
        {
            let destinationVC = segue.destination as! SnapVC
            destinationVC.selectedSnap = chosenSnap
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
