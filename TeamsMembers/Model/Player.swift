//
//  Player.swift
//  TeamsMembers
//
//  Created by Carlos Javier Pendola on 4/27/19.
//  Copyright © 2019 Carlos Javier Pendola. All rights reserved.
//

import UIKit
import FirebaseFirestore

class Player {
    var name          : String
    var image         : String
    var team       : DocumentReference
    var documentReference : DocumentReference?
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "name" : name,
            "image" : image,
            "team" : team,
        ]
    }
    
    init(name: String, image:String ,team: DocumentReference, documentReference: DocumentReference?) {
        self.name = name
        self.image = image
        self.team = team
        self.documentReference = documentReference
    }
    
    convenience init?(documentSnapshot: DocumentSnapshot) {
        guard let documentData = documentSnapshot.data(),
            let name  = documentData["name"] as? String,
            let image = documentData["image"] as? String,
            let team  = documentData["team"] as? DocumentReference
            else {
                print("Player init problem.")
                return nil
        }
        
        let documentReference = FirebaseManager.shared.db.collection("player").document(documentSnapshot.documentID)
        self.init(name: name,image:image, team:team, documentReference:documentReference)
    }
}

