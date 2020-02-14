//
//  ProfileViewController.swift
//  Staffy
//
//  Created by Aidan Miskella on 05/08/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Cosmos
import ImagePicker
import GrowingTextView

class ProfileViewController: UIViewController, ImagePickerDelegate {
    
    @IBOutlet weak var topProfileImageView: UIView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var middleRatingView: UIView!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var bioLabel: GrowingTextView!
    
    @IBOutlet weak var jobAlertView: UIView!
    
    @IBOutlet weak var jobAlertImage: UIImageView!
    
    @IBOutlet weak var jobAlertLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataCells: [ProfileCellData] = []
    private var jobs = [Job]()
    private var jobs_ref: CollectionReference!
    private var jobsListener: ListenerRegistration!
    private var jobsCollectionRef: CollectionReference!
    private var loginHandle: AuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        
        loginHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            if user != nil {
                
                CompanyService.observeCompanyProfile(user!.uid, completion: { (user) in
                    
                    CompanyService.currentCompany = user
                    self.dataCells = self.createArray()
                    self.setUpProfile()
                    self.tableView.reloadData()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
        setUpProfile()
        dataCells = createArray()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        jobsCollectionRef = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
    }
    
    func setUpElements() {

        Utilities.styleLabel(label: ratingLabel, font: .subTitle, fontColor: .gray)
        Utilities.styleTextView(textView: bioLabel, font: .editProfileText, fontColor: .darkGray)
        Utilities.styleLabel(label: jobAlertLabel, font: .subTitle, fontColor: .white)
        
        topProfileImageView.backgroundColor = .lightBlue
        
        middleRatingView.roundCorners([.topLeft, .topRight], radius: 30.0)
        
        bioLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bioTapped)))
        bioLabel.sizeToFit()
        
        jobAlertView.backgroundColor = .lightBlue
        jobAlertImage.tintColor = .white
        
        profileImage.layer.borderWidth = 4
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.gray.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageTapped)))
        
        Utilities.setupNavigationStyleNoBorder(navigationController!)
    }
    
    func setUpProfile() {
        
        guard let currentCompany = CompanyService.currentCompany else { return }
        
        ImageService.getImage(withURL: currentCompany.avatarURL!) { (image) in
            
            self.profileImage.image = image
        }
        
        ratingView.rating = getStarRating()
        ratingLabel.text = getRatingText()
        bioLabel.text = currentCompany.bio
    }
    
    func getStarRating() -> Double {
        
        if CompanyService.currentCompany?.reviewRating == 0 {
            
            return 0
        } else {
            
            return (CompanyService.currentCompany!.reviewRating! / Double(CompanyService.currentCompany!.jobsCompleted))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if jobsListener != nil {
            
            jobsListener.remove()
        }
    }
    
    func setListener() {
        
        guard let currentCompanyId = Auth.auth().currentUser?.uid else { return }
        
        jobsListener = jobsCollectionRef
            .whereField(Constants.FirebaseDB.company_id, isEqualTo: currentCompanyId)
            .whereField(Constants.FirebaseDB.status, isEqualTo: "open")
            .order(by: Constants.FirebaseDB.start_date, descending: false)
            .addSnapshotListener({ (snapshot, error) in
                
                if let error = error {
                    
                    debugPrint("Error fetching docs: \(error)")
                } else {
                    
                    self.jobs.removeAll()
                    self.jobs = Job.parseData(snapshot: snapshot)
                    self.getJobs()
                }
            })
    }

    func getJobs() {
        
        if jobs.count == 0 {
            
            jobAlertLabel.text = "You have no upcoming jobs, create a new job in the 'My Jobs' tab"
        } else {
            
            jobAlertLabel.text = "You have \(jobs.count) upcoming jobs, starting on the \(Utilities.dateFormatterFullMonth(jobs[0].startDate.dateValue())) at \(jobs[0].startTime)"
        }
    }
    
    func getRatingText() -> String {
        
        if CompanyService.currentCompany?.reviewRating == 0 {
            
            return "No reviews yet"
        } else {
            
            let rating = (CompanyService.currentCompany!.reviewRating! / Double(CompanyService.currentCompany!.jobsCompleted))
            return String(format: "%.1f of 5 Star Rating", rating)
        }
    }
    
    @objc private func profileImageTapped(_ recognizer: UITapGestureRecognizer) {
        
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func bioTapped(_ recognizer: UITapGestureRecognizer) {
        
        self.performSegue(withIdentifier: "Bio", sender: self)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        imagePicker.dismiss(animated: true)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        // Get the users avatarURL
        let ref = Firestore.firestore().collection(Constants.FirebaseDB.company_ref)
            .document(Auth.auth().currentUser!.uid)
        let storageRef = Storage.storage().reference().child("company_avatars").child(Auth.auth().currentUser!.uid)
        
        if let uploadData = images[0].jpegData(compressionQuality: 0.5) {
            
            storageRef.putData(uploadData, metadata: nil) { (metaData, error) in
                
                if let error = error {
                    
                    debugPrint("Error storing image: \(error.localizedDescription)")
                } else {
                    
                    storageRef.downloadURL { (url, error) in
                        
                        guard let avatarURL = url else { return }
                        ref.updateData(["avatarURL": avatarURL.absoluteString], completion: { (error) in
                            
                            self.profileImage.image = images[0]
                        })
                    }
                }
            }
        }

        imagePicker.dismiss(animated: true)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
        imagePicker.dismiss(animated: true)
    }
    
    func setGradientBackground() {
        
        let colorTop =  UIColor(red: 149/255, green: 209/255, blue: 237/255, alpha: 1).cgColor
        let colorBottom = UIColor(red: 45/255, green: 171/255, blue: 235/255, alpha: 1).cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = topProfileImageView.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func createArray() -> [ProfileCellData] {
        
        var tempCells: [ProfileCellData] = []
        guard let currentCompany = CompanyService.currentCompany else { return tempCells }
        
        let companyName = ProfileCellData(title: "Company", data: currentCompany.companyName)
        let nameCell = ProfileCellData(title: "Name", data: "\(currentCompany.firstName) \(currentCompany.lastName)")
        let emailCell = ProfileCellData(title: "Email", data: (Auth.auth().currentUser?.email)!)
        let mobileCell = ProfileCellData(title: "Mobile", data: currentCompany.mobile!)
        let addressCell = ProfileCellData(title: "Address", data: currentCompany.address!)
        let passwordCell = ProfileCellData(title: "Password", data: "*********")
        
        tempCells.append(companyName)
        tempCells.append(nameCell)
        tempCells.append(emailCell)
        tempCells.append(mobileCell)
        tempCells.append(addressCell)
        tempCells.append(passwordCell)
        
        return tempCells
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
        do {
            
            try Auth.auth().signOut()
        } catch let signoutError as NSError {
            
            debugPrint("Error signing out: \(signoutError)")
        }
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let profileData = dataCells[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileTableViewCell
        
        cell.setCell(profileData: profileData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: dataCells[indexPath.row].title, sender: self)
    }

}

