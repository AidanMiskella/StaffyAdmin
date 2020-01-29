//
//  UserProfileViewController.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 05/11/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Cosmos
import ImagePicker
import GrowingTextView

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var topProfileImageView: UIView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var middleRatingView: UIView!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var bioLabel: GrowingTextView!
    
    @IBOutlet weak var jobAlertView: UIView!
    
    @IBOutlet weak var jobAlertImage: UIImageView!
    
    @IBOutlet weak var jobAlertLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataCells: [ProfileCellData] = []
    var user: User!
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpProfile()
        dataCells = createArray()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
        topProfileImageView.backgroundColor = .lightBlue
        dataCells = createArray()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setUpElements() {
        
        Utilities.styleLabel(label: ratingLabel, font: .subTitle, fontColor: .gray)
        Utilities.styleTextView(textView: bioLabel, font: .subTitle, fontColor: .darkGray)
        Utilities.styleLabel(label: jobAlertLabel, font: .subTitle, fontColor: .white)
        
        middleRatingView.roundCorners([.topLeft, .topRight], radius: 30.0)
        
        bioLabel.sizeToFit()
        
        jobAlertView.backgroundColor = .lightBlue
        jobAlertImage.tintColor = .white
        jobAlertLabel.text = "\(user.firstName) has completed \(user.jobsCompleted!) job since joining in \(user.dateProfileCreated)"
        
        profileImage.layer.borderWidth = 4
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        
        Utilities.setupNavigationStyleNoBorder(navigationController!)
    }
    
    func setUpProfile() {
        
        ImageService.getImage(withURL: user.avatarURL!) { (image) in
            
            self.profileImage.image = image
        }
        
        ratingView.rating = getStarRating()
        ratingLabel.text = getRatingText()
        bioLabel.text = user.bio
        
    }
    
    func getStarRating() -> Double {
        
        if user.reviewRating == 0 {
            
            return 0
        } else {
            
            return (user.reviewRating! / Double(user.jobsCompleted!))
        }
    }
    
    func getRatingText() -> String {
        
        if user.reviewRating == 0 {
            
            return "No reviews yet"
        } else {
            
            let rating = (user.reviewRating! / Double(user.jobsCompleted!))
            return String(format: "%.1f of 5 Star Rating", rating)
        }
    }
    
    func createArray() -> [ProfileCellData] {
        
        var tempCells: [ProfileCellData] = []
        
        let nameCell = ProfileCellData(title: "Name", data: "\(user.firstName) \(user.lastName)")
        let emailCell = ProfileCellData(title: "Email", data: "\(user.email)")
        let dateOfBirthCell = ProfileCellData(title: "Date of Birth", data: user.dateOfBirth!)
        let genderCell = ProfileCellData(title: "Gender", data: user.gender!)
        let mobileCell = ProfileCellData(title: "Mobile", data: user.mobile!)
        let addressCell = ProfileCellData(title: "Address", data: user.address!)
        let documentsCell = ProfileCellData(title: "Documents", data: "\(user.documents!.count) Documents")
        
        tempCells.append(nameCell)
        tempCells.append(emailCell)
        tempCells.append(dateOfBirthCell)
        tempCells.append(genderCell)
        tempCells.append(mobileCell)
        tempCells.append(addressCell)
        tempCells.append(documentsCell)
        
        return tempCells
    }
}

extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let profileData = dataCells[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileTableViewCell
        
        cell.setCell(profileData: profileData)
        
        return cell
    }
}
