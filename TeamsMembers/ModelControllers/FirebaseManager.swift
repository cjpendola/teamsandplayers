//
//  FirebaseManager.swift
//  TeamsMembers
//
//  Created by Carlos Javier Pendola on 4/27/19.
//  Copyright © 2019 Carlos Javier Pendola. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseManager {
    
    let db = Firestore.firestore()
    static let shared = FirebaseManager()
    var listenerPlayers:ListenerRegistration?
    
    var teams: [Team] = [] {
        didSet {
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTeams"), object: nil)
        }
    }
    var players: [Player] = [] {
        didSet {
        }
    }
    
    func fetchTeams(completion: @escaping (Bool) -> Void) {
        print("fetchTeams")
        db.collection("team").addSnapshotListener { (querySnapshot, error) in
            if querySnapshot?.documents == nil || error != nil {
                print("Error querying teams: \((error, error!.localizedDescription))")
                completion(false)
            } else {
                self.teams = []
                for doc in querySnapshot!.documents {
                    if let team = Team(documentSnapshot: doc) {
                        self.teams.append(team)
                    }
                }
                print("Teams listed")
                completion(true)
            }
        }
    }
    
    func fetchPLayer(team:Team,completion: @escaping (Bool) -> Void) {
        print("fetchPLayer")
        guard let teamRef =  team.documentReference else{
            completion(false)
            return
        }
        db.collection("player").whereField("team", isEqualTo: teamRef).addSnapshotListener { (querySnapshot, error) in
            if querySnapshot?.documents == nil || error != nil {
                print("Error querying player : \((error, error!.localizedDescription))")
                completion(false)
                return
            } else {
                self.players = []
                for doc in querySnapshot!.documents {
                    if let player = Player(documentSnapshot: doc) {
                        self.players.append(player)
                    }
                }
                print("Players listed")
                completion(true)
                return
            }
        }
    }
    
    func removeTeam(team:Team, completion: @escaping(Bool) -> Void ){
        
        guard let teamRef = team.documentReference else {
            completion(false)
            return
        }
        teamRef.delete() { err in
            if let err = err {
                print("Error removing team: \(err)")
                completion(false)
                return
            } else {
                print("Document successfully removed!")
                completion(true)
                return
            }
        }
    }
    
    func removePlayer(player:Player, completion: @escaping(Bool) -> Void ){
        
        guard let playerRef = player.documentReference else {
            completion(false)
            return
        }
        
        playerRef.delete() { err in
            if let err = err {
                print("Error removing player: \(err)")
                completion(false)
                return
            } else {
                print("Document successfully removed!")
                completion(true)
                return
            }
        }
    }
    
    
    func uploadTeam(name:String, image:UIImage, completion: @escaping(Bool) -> Void ){
       
        let filename = "avatar.png"
        let boundary = UUID().uuidString
        let fieldName = "reqtype"
        let fieldValue = "fileupload"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: URL(string: "https://catbox.moe/user/api.php")!)
        urlRequest.httpMethod = "POST"
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data in a web browser
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue)".data(using: .utf8)!)
        
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            
            if(error != nil){
                print("\(error!.localizedDescription)")
            }
            
            guard let responseData = responseData else {
                print("no response data")
                return
            }
            
            print( responseData )
            if let responseString = String(data: responseData, encoding: .utf8) {
                print("uploaded to: \(responseString)")
               
                let team = Team(name: name, image: responseString, documentReference: nil)
                let newDocumentID = UUID().uuidString
                self.db.collection("team").document(newDocumentID).setData(team.dictionaryRepresentation) { error in
                    if let error = error {
                        print("Error adding team: \((error, error.localizedDescription))")
                        completion(false)
                        return
                    }
                    else{
                        print("I added a team to firebase")
                        completion(true)
                        return
                    }
                }
            }
        }).resume()
    }
    
    
    
    func updateTeam(team:Team,name:String, image:UIImage, completion: @escaping(Bool) -> Void ){
        
        let filename = "avatar.png"
        let boundary = UUID().uuidString
        let fieldName = "reqtype"
        let fieldValue = "fileupload"
        
        guard let teamRef =  team.documentReference else { completion(false);  return}
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: URL(string: "https://catbox.moe/user/api.php")!)
        urlRequest.httpMethod = "POST"
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data in a web browser
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue)".data(using: .utf8)!)
        
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            if(error != nil){
                print("\(error!.localizedDescription)")
            }
            guard let responseData = responseData else {
                print("no response data")
                return
            }
            print( responseData )
            if let responseString = String(data: responseData, encoding: .utf8) {
                print("uploaded to: \(responseString)")
                teamRef.updateData([
                    "name" : name,
                    "image" : responseString,
                ]) { error in
                    if let error = error {
                        print("Error updating team: \((error, error.localizedDescription))")
                        completion(false)
                        return
                    }
                    completion(true)
                    return
                }
            }
        }).resume()
    }
    
    
    
    
    
    
    func uploadPlayer(team:Team, name:String, image:UIImage, height:String,weight :String, fouls:String, points:String, completion: @escaping(Bool) -> Void ){
        
        let filename = "avatar.png"
        let boundary = UUID().uuidString
        let fieldName = "reqtype"
        let fieldValue = "fileupload"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: URL(string: "https://catbox.moe/user/api.php")!)
        urlRequest.httpMethod = "POST"
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data in a web browser
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue)".data(using: .utf8)!)
        
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            
            if(error != nil){
                print("\(error!.localizedDescription)")
            }
            
            guard let responseData = responseData else {
                print("no response data")
                return
            }
            
            print( responseData )
            if let responseString = String(data: responseData, encoding: .utf8) {
                print("uploaded to: \(responseString)")
                
                guard let teamRef = team.documentReference else {
                    completion(false)
                    return
                }
                let player = Player(name: name, image: responseString,team:teamRef, height:height,weight :weight, fouls:fouls, points:points,  documentReference: nil)
                let playerDocumentID = UUID().uuidString
                self.db.collection("player").document(playerDocumentID).setData(player.dictionaryRepresentation) { error in
                    if let error = error {
                        print("Error adding player: \((error, error.localizedDescription))")
                        completion(false)
                        return
                    }
                    else{
                        print("I added a player to firebase")
                        teamRef.updateData([
                            "players" : FieldValue.arrayUnion([playerDocumentID])
                        ]) { error in
                            if let error = error {
                                print("Error updating team player's array: \((error, error.localizedDescription))")
                                completion(false)
                                return
                            } else {
                                print("Successfully updated team player's  array")
                                completion(true)
                                return
                            }
                        }
                    }
                }
            }
        }).resume()
    }
    
    
    func updatePlayer(player:Player,name:String, image:UIImage,height:String,weight :String, fouls:String, points:String, completion: @escaping(Bool) -> Void ){
        
        let filename = "avatar.png"
        let boundary = UUID().uuidString
        let fieldName = "reqtype"
        let fieldValue = "fileupload"
        
        guard let playerRef =  player.documentReference else { completion(false);  return}
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: URL(string: "https://catbox.moe/user/api.php")!)
        urlRequest.httpMethod = "POST"
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data in a web browser
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue)".data(using: .utf8)!)
        
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            if(error != nil){
                print("\(error!.localizedDescription)")
            }
            guard let responseData = responseData else {
                print("no response data")
                return
            }
            print( responseData )
            if let responseString = String(data: responseData, encoding: .utf8) {
                print("uploaded to: \(responseString)")
                playerRef.updateData([
                    "name" : name,
                    "image" : responseString,
                    "height" : height,
                    "weight" : weight,
                    "fouls" : fouls,
                    "points" : points,
                ]) { error in
                    if let error = error {
                        print("Error updating player: \((error, error.localizedDescription))")
                        completion(false)
                        return
                    }
                    completion(true)
                    return
                }
            }
        }).resume()
    }
    
    
    
}


