//
//  Team.swift
//  TeamsMembers
//
//  Created by Carlos Javier Pendola on 4/27/19.
//  Copyright © 2019 Carlos Javier Pendola. All rights reserved.
//

import UIKit
import FirebaseFirestore

class Team {
    var name          : String
    var image         : String
    var documentReference : DocumentReference?
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "name"    : name,
            "image"   : image
        ]
    }
    
    init(name: String, image:String , documentReference: DocumentReference?) {
        self.name = name
        self.image = image
    
        self.documentReference = documentReference
    }
    
    convenience init?(documentSnapshot: DocumentSnapshot) {
        guard let documentData = documentSnapshot.data(),
              let name = documentData["name"] as? String,
              let image = documentData["image"] as? String
        else {
                print("Team init problem.")
                return nil
        }
        
        let documentReference = FirebaseManager.shared.db.collection("team").document(documentSnapshot.documentID)
        self.init(name: name,image:image, documentReference:documentReference)
    }
}
