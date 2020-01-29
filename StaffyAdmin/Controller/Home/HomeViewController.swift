//
//  HomeViewController.swift
//  Staffy
//
//  Created by Aidan Miskella on 04/08/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SCLAlertView

enum StatusCategory: String {
    
    case open = "OPEN"
    case in_progress = "IN-PROGRESS"
    case closed = "CLOSED"
}

class HomeViewController: UIViewController {
    
    private var jobs = [Job]()
    private var jobs_ref: CollectionReference!
    private var jobsListener: ListenerRegistration!
    private var jobsCollectionRef: CollectionReference!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    
    private var loginHandle: AuthStateDidChangeListenerHandle?
    private var selectedCategory = StatusCategory.open.rawValue
    private var currentJob: Job?
    private var selectedJob: Job?
    var filteredJobs: [Job] = []
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setup()
        getJobCount()
        segmentControl.tintColor = .lightBlue
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        jobsCollectionRef = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
    }
    
    override func viewWillAppear(_ animated: Bool) {

        loginHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            if user != nil {
                
                CompanyService.observeCompanyProfile(user!.uid, completion: { (user) in
                    
                    CompanyService.currentCompany = user
                    self.setListener()
                })
            } else {
            
                CompanyService.currentCompany = nil
                
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.loginViewController)
                self.present(loginVC, animated: true, completion: nil)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if jobsListener != nil {
            
            jobsListener.remove()
        }
    }
    
    func getJobCount() {
        
        guard let currentCompanyId = Auth.auth().currentUser?.uid else { return }
        
        let openArray = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
            .whereField(Constants.FirebaseDB.company_id, isEqualTo: currentCompanyId)
            .whereField(Constants.FirebaseDB.status, isEqualTo: "open")
        openArray.getDocuments { (snapshot, error) in
            
            self.segmentControl.setTitle("OPEN (\(snapshot!.count))", forSegmentAt: 0)
        }
        
        let inprogressArray = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
            .whereField(Constants.FirebaseDB.company_id, isEqualTo: currentCompanyId)
            .whereField(Constants.FirebaseDB.status, isEqualTo: "inProgress")
        inprogressArray.getDocuments { (snapshot, error) in
            
            self.segmentControl.setTitle("IN-PROGRESS (\(snapshot!.count))", forSegmentAt: 1)
        }
        
        let closedArray = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
            .whereField(Constants.FirebaseDB.company_id, isEqualTo: currentCompanyId)
            .whereField(Constants.FirebaseDB.status, isEqualTo: "closed")
        closedArray.getDocuments { (snapshot, error) in
            
            self.segmentControl.setTitle("CLOSED (\(snapshot!.count))", forSegmentAt: 2)
        }
    }
    
    private func setup() {
        
        Utilities.setupNavigationStyle(navigationController!)
        segmentControl.addUnderlineForSelectedSegment()
        segmentControl.setFontSize()
        searchBar.tintColor = .lightBlue
    }
    
    @IBAction func categoryChanged(_ sender: Any) {
        
        searchBar.text = ""
        searchBar.endEditing(true)
        searchActive = false
        
        segmentControl.changeUnderlinePosition()
        
        if segmentControl.selectedSegmentIndex == 0 {
            
            selectedCategory = StatusCategory.open.rawValue
        } else if segmentControl.selectedSegmentIndex == 1 {
            
            selectedCategory = StatusCategory.in_progress.rawValue
        } else {
            
            selectedCategory = StatusCategory.closed.rawValue
        }
        
        jobsListener.remove()
        setListener()
    }
    
    func setListener() {
        
        guard let currentCompanyId = Auth.auth().currentUser?.uid else { return }
        
        if selectedCategory == StatusCategory.open.rawValue {
            
            jobsListener = jobsCollectionRef
                .whereField(Constants.FirebaseDB.company_id, isEqualTo: currentCompanyId)
                .whereField(Constants.FirebaseDB.status, isEqualTo: "open")
                .order(by: Constants.FirebaseDB.posted_date, descending: true)
                .addSnapshotListener({ (snapshot, error) in
                    
                    if let error = error {
                        
                        debugPrint("Error fetching docs: \(error)")
                    } else {
                        
                        self.jobs.removeAll()
                        self.jobs = Job.parseData(snapshot: snapshot)
                        self.getJobCount()
                        self.tableView.reloadData()
                    }
                })
        } else if selectedCategory == StatusCategory.in_progress.rawValue {
            
            jobsListener = jobsCollectionRef
                .whereField(Constants.FirebaseDB.company_id, isEqualTo: currentCompanyId)
                .whereField(Constants.FirebaseDB.status, isEqualTo: "inProgress")
                .order(by: Constants.FirebaseDB.posted_date, descending: true)
                .addSnapshotListener({ (snapshot, error) in
                    
                    if let error = error {
                        
                        debugPrint("Error fetching docs: \(error)")
                    } else {
                        
                        self.jobs.removeAll()
                        self.jobs = Job.parseData(snapshot: snapshot)
                        self.getJobCount()
                        self.tableView.reloadData()
                    }
                })
        } else {
            
            jobsListener = jobsCollectionRef
                .whereField(Constants.FirebaseDB.company_id, isEqualTo: currentCompanyId)
                .whereField(Constants.FirebaseDB.status, isEqualTo: "closed")
                .order(by: Constants.FirebaseDB.posted_date, descending: true)
                .addSnapshotListener({ (snapshot, error) in
                    
                    if let error = error {
                        
                        debugPrint("Error fetching docs: \(error)")
                    } else {
                        
                        self.jobs.removeAll()
                        self.jobs = Job.parseData(snapshot: snapshot)
                        self.getJobCount()
                        self.tableView.reloadData()
                    }
                })
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchActive) {
            return filteredJobs.count
        }
        return jobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var job: Job
        
        if(searchActive) {
            job = filteredJobs[indexPath.row]
        } else {
            job = jobs[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell") as! JobTableViewCell
        
        cell.setCell(job: job)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        selectedJob = jobs[indexPath.row]
        performSegue(withIdentifier: "goToJobDetails", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToJobDetails" {
            
            let vc = segue.destination as! JobViewController
            vc.job = selectedJob
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    
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
        
        filteredJobs = jobs.filter({$0.title.lowercased().contains(searchText.lowercased()) ||
            $0.address.lowercased().contains(searchText.lowercased())
        })
        
        if(filteredJobs.count == 0){
            searchActive = false
            tableView.endEditing(true)
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
    }
}
