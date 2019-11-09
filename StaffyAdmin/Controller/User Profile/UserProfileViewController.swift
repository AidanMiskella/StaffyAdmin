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

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var topProfileImageView: UIView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var middleRatingView: UIView!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
    
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
        Utilities.styleLabel(label: bioLabel, font: .subTitle, fontColor: .darkGray)
        Utilities.styleLabel(label: jobAlertLabel, font: .subTitle, fontColor: .white)
        
        contentView.roundCorners([.topLeft, .topRight], radius: 30.0)
        
        bioLabel.sizeToFit()
        
        jobAlertView.backgroundColor = .lightBlue
        jobAlertImage.tintColor = .white
        
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
        
        ratingView.rating = user.reviewRating!
        ratingLabel.text = getRatingText(rating: user.reviewRating!)
        bioLabel.text = user.bio
        
    }
    
    func getRatingText(rating: Double) -> String {
        
        switch rating {
            
        case 0:
            return "\(Constants.Profile.no_rating)"
        case 1:
            return "1 \(Constants.Profile.rating)"
        case 2:
            return "2 \(Constants.Profile.rating)"
        case 3:
            return "3 \(Constants.Profile.rating)"
        case 4:
            return "4 \(Constants.Profile.rating)"
        case 5:
            return "5 \(Constants.Profile.rating)"
        default:
            return "\(Constants.Profile.ratingError)"
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
