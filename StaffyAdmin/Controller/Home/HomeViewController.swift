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
import FoldingCell
import SCLAlertView

enum StatusCategory: String {
    
    case open = "OPEN"
    case in_progress = "IN-PROGRESS"
    case closed = "CLOSED"
}

class HomeViewController: UIViewController, JobDelegate {
    
    enum Const {
        
        static let closeCellHeight: CGFloat = 150
        static let openCellHeight: CGFloat = 600
        static let rowsCount = 10
    }
    
    var cellHeights: [CGFloat] = []
    
    private var jobs = [Job]()
    private var jobs_ref: CollectionReference!
    private var jobsListener: ListenerRegistration!
    private var jobsCollectionRef: CollectionReference!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    
    private var loginHandle: AuthStateDidChangeListenerHandle?
    private var selectedCategory = StatusCategory.open.rawValue
    private var currentJob: Job?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setup()
        getJobCount()
        segmentControl.tintColor = .lightBlue
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
        
        cellHeights = Array(repeating: Const.closeCellHeight, count: Const.rowsCount)
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor(displayP3Red: 54/255, green: 76/255, blue: 112/255, alpha: 0.1)
        
        Utilities.setupNavigationStyle(navigationController!)
    }
    
    @IBAction func categoryChanged(_ sender: Any) {
        
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
    
    func manageButtonTapped(job: Job) {
        
        let alert = UIAlertController(title: "Job Options", message: "Manage your job by editing the details, managing the staff or delete the job", preferredStyle: .actionSheet)
        
        let manageAction = UIAlertAction(title: "Manage People", style: .default) { (action) in
        
            self.currentJob = job
            self.performSegue(withIdentifier: "JobManage", sender: self)
        }
        
        let editAction = UIAlertAction(title: "Edit Job", style: .default) { (action) in
            
            self.currentJob = job
            self.performSegue(withIdentifier: "JobEdit", sender: self)
        }
        
        let deleteAction = UIAlertAction(title: "Delete Job", style: .destructive) { (action) in
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(manageAction)
        
        if selectedCategory == StatusCategory.open.rawValue {
            
            let moveToInProgress = UIAlertAction(title: "Move to In-Progress", style: .default) { (action) in
                
                if Calendar.current.isDateInTomorrow(job.startDate.dateValue()) || Calendar.current.isDateInToday(job.startDate.dateValue()) {
                    
                    let ref = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
                        .document(job.jobId)
                    
                    ref.updateData([
                        Constants.FirebaseDB.status: "inProgress"
                    ]) { (error) in
                        
                        if let error = error {
                            
                            print("Error updating information \(error)")
                        } else {
                            
                            print("Updated status")
                            self.getJobCount()
                        }
                    }
                } else {
                    
                    let alertView = SCLAlertView(appearance: Constants.AlertView.appearance)
                    
                    alertView.addButton("Continue", backgroundColor: .lightBlue, textColor: .white) {
                        
                        alertView.dismiss(animated: true)
                    }
                    
                    alertView.showError("Cannot move job", subTitle: "This job doesn't start until \(Utilities.dateFormatterFullMonth(job.startDate.dateValue())). You can only move this job the day before or day of its start date", animationStyle: .rightToLeft)
                }
            }
            alert.addAction(moveToInProgress)
        } else if selectedCategory == StatusCategory.in_progress.rawValue {
            
            let moveToClosed = UIAlertAction(title: "Move to Closed", style: .default) { (action) in
                
                let ref = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
                    .document(job.jobId)
                
                ref.updateData([
                    Constants.FirebaseDB.status: "closed"
                ]) { (error) in
                    
                    if let error = error {
                        
                        print("Error updating information \(error)")
                    } else {
                        
                        print("Updated status")
                        self.getJobCount()
                    }
                }
            }
            alert.addAction(moveToClosed)
        }
        
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "JobEdit" {
            
            let vc = segue.destination as! JobEditViewController
            vc.job = currentJob
        }
        
        if segue.identifier == "JobManage" {
            
            let vc = segue.destination as! ManagePeopleViewController
            vc.job = currentJob
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return jobs.count
    }
    
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as DemoCell = cell else {
            return
        }
        
        cell.backgroundColor = .clear
        
        if cellHeights[indexPath.row] == Const.closeCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! DemoCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        cell.configureCell(job: jobs[indexPath.row], delegate: self)
        return cell
    }
    
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == Const.closeCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = Const.openCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = Const.closeCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
            
            if cell.frame.maxY > tableView.frame.maxY {
                tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }, completion: nil)
    }
}
