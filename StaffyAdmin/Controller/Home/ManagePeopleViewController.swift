//
//  ManagePeopleViewController.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 03/11/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit
import Cosmos
import Firebase
import FirebaseAuth

enum ManagePeopleCategory: String {
    
    case applicants = "APPLICANTS"
    case accepted = "ACCEPTED"
}

class ManagePeopleViewController: UIViewController, UserCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    
    var job: Job!
    var currentUser: User!
    private var users = [User]()
    private var selectedCategory = ManagePeopleCategory.applicants.rawValue
    private var userListener: ListenerRegistration!
    private var userCollectionRef: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getUserCount()
        segmentControl.tintColor = .lightBlue
        
        tableView.delegate = self
        tableView.dataSource = self
        
        userCollectionRef = Firestore.firestore().collection(Constants.FirebaseDB.user_ref)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.setListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if userListener != nil {
            
            userListener.remove()
        }
    }
    
    func getUserCount() {
        
        let applicantsArray = Firestore.firestore().collection(Constants.FirebaseDB.user_ref)
            .whereField(Constants.FirebaseDB.jobs_applied, arrayContains: job.jobId)
        applicantsArray.getDocuments { (snapshot, error) in
            
            self.segmentControl.setTitle("APPLICANTS (\(snapshot!.count))", forSegmentAt: 0)
        }
        
        let acceptedArray = Firestore.firestore().collection(Constants.FirebaseDB.user_ref)
            .whereField(Constants.FirebaseDB.jobs_accepted, arrayContains: job.jobId)
        acceptedArray.getDocuments { (snapshot, error) in
            
            self.segmentControl.setTitle("STAFF (\(snapshot!.count))", forSegmentAt: 1)
        }
    }
    
    @IBAction func categoryChanged(_ sender: Any) {
        
        if segmentControl.selectedSegmentIndex == 0 {
            
            selectedCategory = ManagePeopleCategory.applicants.rawValue
        } else {
            
            selectedCategory = ManagePeopleCategory.accepted.rawValue
        }
        
        userListener.remove()
        setListener()
    }
    
    func setListener() {
        
        if selectedCategory == ManagePeopleCategory.applicants.rawValue {
            
            userListener = userCollectionRef
                .whereField(Constants.FirebaseDB.jobs_applied, arrayContains: job.jobId)
                .addSnapshotListener { (snapshot, error) in
                    
                    if let error = error {
                        
                        debugPrint("Error fetching docs: \(error)")
                    } else {
                        
                        self.users.removeAll()
                        self.users = User.parseData(snapshot: snapshot)
                        self.getUserCount()
                        self.tableView.reloadData()
                    }
            }
        } else {
            
            userListener = userCollectionRef
                .whereField(Constants.FirebaseDB.jobs_accepted, arrayContains: job.jobId)
                .addSnapshotListener { (snapshot, error) in
                    
                    if let error = error {
                        
                        debugPrint("Error fetching docs: \(error)")
                    } else {
                        
                        self.users.removeAll()
                        self.users = User.parseData(snapshot: snapshot)
                        self.getUserCount()
                        self.tableView.reloadData()
                    }
            }
        }
    }
    
    func moreButtonTapped(user: User) {
        
        if job.status == "open" {
        
            if selectedCategory == ManagePeopleCategory.applicants.rawValue {
            
                let alert = UIAlertController(title: "People Options", message: "Accept or decline \(user.firstName)'s application. If accepted, \(user.firstName) will appear in accepted staff", preferredStyle: .actionSheet)

                let acceptAction = UIAlertAction(title: "Accept", style: .default) { (action) in

                    let batch = Firestore.firestore().batch()
                    
                    // Update job applicants
                    let job_ref = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
                        .document(self.job.jobId)
                    
                    batch.updateData([
                        Constants.FirebaseDB.applicants: FieldValue.arrayRemove([user.userId])
                        ], forDocument: job_ref)
                    
                    // Update jobs applied/accepted for
                    let user_ref = Firestore.firestore().collection(Constants.FirebaseDB.user_ref)
                        .document(user.userId)
                    
                    batch.updateData([
                        Constants.FirebaseDB.jobs_applied: FieldValue.arrayRemove([self.job.jobId]),
                        Constants.FirebaseDB.jobs_accepted: FieldValue.arrayUnion([self.job.jobId])
                        ], forDocument: user_ref)
                    
                    batch.commit() { err in
                        if let err = err {
                            
                            print("Error writing batch \(err)")
                        } else {
                            
                            self.getUserCount()
                        }
                    }
                }

                let declineAction = UIAlertAction(title: "Decline", style: .destructive) { (action) in

                    let batch = Firestore.firestore().batch()
                    
                    // Update jobs accepted for
                    let user_ref = Firestore.firestore().collection(Constants.FirebaseDB.user_ref)
                        .document(user.userId)
                    
                    batch.updateData([
                        Constants.FirebaseDB.jobs_applied: FieldValue.arrayRemove([self.job.jobId])
                        ], forDocument: user_ref)
                    
                    batch.commit() { err in
                        if let err = err {
                            
                            print("Error writing batch \(err)")
                        } else {
                            
                            self.getUserCount()
                        }
                    }
                }

                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(acceptAction)
                alert.addAction(declineAction)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            } else {
                
                let alert = UIAlertController(title: "People Options", message: "Remove \(user.firstName)'s application. If removed, \(user.firstName) will have to apply to the job again", preferredStyle: .actionSheet)
                
                let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (action) in
                    
                    let batch = Firestore.firestore().batch()
                    
                    // Update jobs accepted for
                    let user_ref = Firestore.firestore().collection(Constants.FirebaseDB.user_ref)
                        .document(user.userId)
                    
                    batch.updateData([
                        Constants.FirebaseDB.jobs_accepted: FieldValue.arrayRemove([self.job.jobId])
                        ], forDocument: user_ref)
                    
                    batch.commit() { err in
                        if let err = err {
                            
                            print("Error writing batch \(err)")
                        } else {
                            
                            self.getUserCount()
                        }
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(removeAction)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            }
        } else {
            
            if selectedCategory == ManagePeopleCategory.applicants.rawValue {
                
                
            } else {
                
                let alert = UIAlertController(title: "Staff Options", message: "View \(user.firstName)'s work details. This includes clock in and out and also any details of the job", preferredStyle: .actionSheet)
                
                let viewWork = UIAlertAction(title: "Job Details", style: .default) { (action) in
                    
                    
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(viewWork)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func profileButtonTapped(user: User) {
        
        currentUser = user
        self.performSegue(withIdentifier: "userProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "userProfile" {
            
            let vc = segue.destination as! UserProfileViewController
            vc.user = currentUser
        }
    }
}

extension ManagePeopleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManagePeopleCell") as! ManagePeopleCell

        cell.setCell(user: user, delegate: self)

        return cell
    }
}
