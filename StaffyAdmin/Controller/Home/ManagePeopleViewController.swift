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

class ManagePeopleViewController: UIViewController, UserCellDelegate, UserCellApplicantDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    
    var job: Job!
    var currentUser: User!
    private var users = [User]()
    
    var filteredUsers: [User] = []
    var searchActive : Bool = false
    
    private var selectedCategory = ManagePeopleCategory.applicants.rawValue
    private var userListener: ListenerRegistration!
    private var userCollectionRef: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getUserCount()
        segmentControl.tintColor = .lightBlue
        searchBar.tintColor = .lightBlue
        segmentControl.addUnderlineForSelectedSegment()
        segmentControl.setFontSize()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
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
        
        if job.status == "open" {
            
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
        } else {
            
            let applicantsArray = Firestore.firestore().collection(Constants.FirebaseDB.user_ref)
                .whereField(Constants.FirebaseDB.all_applications, arrayContains: job.jobId)
            applicantsArray.getDocuments { (snapshot, error) in
                
                self.segmentControl.setTitle("APPLICANTS (\(snapshot!.count))", forSegmentAt: 0)
            }
            
            let acceptedArray = Firestore.firestore().collection(Constants.FirebaseDB.user_ref)
                .whereField(Constants.FirebaseDB.jobs_accepted, arrayContains: job.jobId)
            acceptedArray.getDocuments { (snapshot, error) in
                
                self.segmentControl.setTitle("STAFF (\(snapshot!.count))", forSegmentAt: 1)
            }
        }
    }
    
    @IBAction func categoryChanged(_ sender: Any) {
        
        searchBar.text = ""
        searchBar.endEditing(true)
        searchActive = false
        
        segmentControl.changeUnderlinePosition()
        
        if segmentControl.selectedSegmentIndex == 0 {
            
            selectedCategory = ManagePeopleCategory.applicants.rawValue
        } else {
            
            selectedCategory = ManagePeopleCategory.accepted.rawValue
        }
        
        userListener.remove()
        setListener()
    }
    
    func setListener() {
        
        if job.status == "open" {
        
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
        } else {
            
            if selectedCategory == ManagePeopleCategory.applicants.rawValue {
                
                userListener = userCollectionRef
                    .whereField(Constants.FirebaseDB.all_applications, arrayContains: job.jobId)
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
    }

    func moreButtonTapped(user: User) {
        
        currentUser = user
        
        if job.status == "open" {
        
            if selectedCategory == ManagePeopleCategory.applicants.rawValue {
            
                let alert = UIAlertController(title: "People Options", message: "Accept or decline \(user.firstName)'s application. If accepted, \(user.firstName) will appear in accepted staff", preferredStyle: .actionSheet)

                let acceptAction = UIAlertAction(title: "Accept", style: .default) { (action) in
                    
                    let report_ref = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref).document(self.job.jobId).collection(Constants.FirebaseDB.reports_ref)
                    
                    let reportDoc = report_ref.document()
                    reportDoc.setData([
                        
                        Constants.FirebaseDB.user_id: user.userId,
                        Constants.FirebaseDB.report_id: reportDoc.documentID,
                        Constants.FirebaseDB.report_status: "Not clocked in",
                        Constants.FirebaseDB.clocking_messages: [],
                        Constants.FirebaseDB.employer_star_rating: 0.0,
                        Constants.FirebaseDB.employer_comment: "No comment",
                        Constants.FirebaseDB.employee_star_rating: 0.0,
                        Constants.FirebaseDB.employee_comment: "Not comment",
                        Constants.FirebaseDB.signature_employer_name: "",
                        Constants.FirebaseDB.signature_employer_position: "",
                        Constants.FirebaseDB.signature_url: "",
                        Constants.FirebaseDB.report_open: true
                        
                        ], completion: { (error) in
                        if let error = error {
                            
                            debugPrint("Error adding document: \(error)")
                        } else {
                            
                
                        }
                    })
                    
                    let batch = Firestore.firestore().batch()
                    
                    // Update job applicants
                    let job_ref = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
                        .document(self.job.jobId)
                    
                    batch.updateData([
                        Constants.FirebaseDB.applicants: FieldValue.arrayRemove([user.userId]),
                        Constants.FirebaseDB.accepted: FieldValue.arrayUnion([user.userId])
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
                    
                    let job_ref = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
                        .document(self.job.jobId)
                    
                    batch.updateData([
                        Constants.FirebaseDB.applicants: FieldValue.arrayRemove([user.userId])
                        ], forDocument: job_ref)
                    
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
                        Constants.FirebaseDB.jobs_accepted: FieldValue.arrayRemove([self.job.jobId]),
                        Constants.FirebaseDB.all_applications: FieldValue.arrayRemove([self.job.jobId])
                        ], forDocument: user_ref)
                    
                    let job_ref = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
                        .document(self.job.jobId)
                    
                    batch.updateData([
                        Constants.FirebaseDB.accepted: FieldValue.arrayRemove([user.userId])
                        ], forDocument: job_ref)
                    
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
        } else if job.status == "inProgress" {
            
            if selectedCategory == ManagePeopleCategory.accepted.rawValue {
                
                let alert = UIAlertController(title: "Staff Options", message: "View \(user.firstName)'s work details. This includes clock in and out and also any details of the job", preferredStyle: .actionSheet)
                
                let viewReport = UIAlertAction(title: "View Report", style: .default) { (action) in
                    
                    self.performSegue(withIdentifier: "viewreport", sender: self)
                }
                
                let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (action) in
                    
                    let batch = Firestore.firestore().batch()
                    
                    // Update jobs accepted for
                    let user_ref = Firestore.firestore().collection(Constants.FirebaseDB.user_ref)
                        .document(user.userId)
                    
                    batch.updateData([
                        Constants.FirebaseDB.jobs_accepted: FieldValue.arrayRemove([self.job.jobId]),
                        Constants.FirebaseDB.all_applications: FieldValue.arrayRemove([self.job.jobId])
                        ], forDocument: user_ref)
                    
                    let job_ref = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
                        .document(self.job.jobId)
                    
                    batch.updateData([
                        Constants.FirebaseDB.accepted: FieldValue.arrayRemove([user.userId])
                        ], forDocument: job_ref)
                    
                    batch.commit() { err in
                        if let err = err {
                            
                            print("Error writing batch \(err)")
                        } else {
                            
                            self.getUserCount()
                        }
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(viewReport)
                alert.addAction(removeAction)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            }
        } else {
            
            if selectedCategory == ManagePeopleCategory.accepted.rawValue {
                
                let alert = UIAlertController(title: "Staff Options", message: "View \(user.firstName)'s work details. This includes clock in and out and also any details of the job", preferredStyle: .actionSheet)
                
                let viewReport = UIAlertAction(title: "View Report", style: .default) { (action) in
                    
                    self.performSegue(withIdentifier: "viewreport", sender: self)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(viewReport)
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
        
        if segue.identifier == "viewreport" {
            
            let vc = segue.destination as! ReportViewController
            vc.job = job
            vc.currentUser = currentUser
        }
        
        if segue.identifier == "employerFeedback" {
            
            let vc = segue.destination as! EmployerFeedbackViewController
            vc.job = job
        }
    }
    
    func getReport(user: User, completion: @escaping (Report) -> ()) {
        
        Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
            .document(job!.jobId).collection(Constants.FirebaseDB.reports_ref)
            .whereField(Constants.FirebaseDB.user_id, isEqualTo: user.userId)
            .getDocuments { (snapshot, error) in
                
                let reports = Report.parseData(snapshot: snapshot)
                if reports.count > 0 {
                    
                    completion(reports[0])
                }
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
        
        if selectedCategory == ManagePeopleCategory.accepted.rawValue {
            
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "ManageStaffCell") as! ManageStaffCell
            
            getReport(user: user, completion: { (report) -> Void in
                
                cell2.setCell(user: user, userReport: report, delegate: self)
            })
            return cell2
        } else {
            
            cell.setCell(user: user, delegate: self)
            cell.removeOptionsButton(job: job, selectedSegment: selectedCategory)
            return cell
        }
    }
}

extension ManagePeopleViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.endEditing(true)
        searchActive = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredUsers = users.filter({"\($0.firstName + " " + $0.lastName)".lowercased() .contains(searchText.lowercased().trimmingCharacters(in: .whitespaces))})
        print(filteredUsers.count)
        if(filteredUsers.count == 0){
            searchActive = false
            tableView.endEditing(true)
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
    }
}
