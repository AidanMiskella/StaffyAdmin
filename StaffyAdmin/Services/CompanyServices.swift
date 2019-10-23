//
//  UserServices.swift
//  Staffy
//
//  Created by Aidan Miskella on 19/09/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class CompanyService {
    
    static var currentCompany: Company?
    
    static func observeUserProfile(_ userId: String, completion: @escaping ((_ company: Company?)->())) {
        
        let companyRef = Firestore.firestore().collection(Constants.FirebaseDB.company_ref)
            .document(userId)
        
        companyRef.getDocument { (snapshot, err) in
            
            var company: Company?
            
            if let error = err {
                
                print(error)
            } else {
            
                if let data = snapshot?.data() {
                    
                    if let companyName = data[Constants.FirebaseDB.company_name] as? String,
                    let firstName = data[Constants.FirebaseDB.first_name] as? String,
                    let lastName = data[Constants.FirebaseDB.last_name] as? String,
                    let avatarURL = data[Constants.FirebaseDB.avatar_url] as? String,
                    let bio = data[Constants.FirebaseDB.bio] as? String,
                    let reviewRating = data[Constants.FirebaseDB.reviewRating] as? Float,
                    let mobile = data[Constants.FirebaseDB.mobile] as? String,
                    let address = data[Constants.FirebaseDB.address] as? String,
                    let dateProfileCreated = data[Constants.FirebaseDB.date_created] as? String,
                    let jobsCreated = data[Constants.FirebaseDB.jobs_created] as? [Any],
                    let url = URL(string: avatarURL) {
                        
                        company = Company(userId: userId, companyName: companyName, firstName: firstName, lastName: lastName, avatarURL: url, bio: bio, reviewRating: reviewRating, mobile: mobile, address: address, dateProfileCreated: dateProfileCreated, jobsCreated: jobsCreated)
                    }
                    
                    completion(company)
                }
            }
        }
    }
}
