//
//  TeamViewViewController.swift
//  TeamsMembers
//
//  Created by Carlos Javier Pendola on 4/27/19.
//  Copyright © 2019 Carlos Javier Pendola. All rights reserved.
//

import UIKit

class TeamViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var photoCell: ProfileTableViewCell!
    @IBOutlet weak var photoCellImage: RoundImageView!
    @IBOutlet weak var nameText: UITextField!
    
    // MARK: - Properties
    var team:Team?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.delegate = self
        photoCell.delegate = self
        updateViews()
    }
    
    func updateViews(){
        guard let team = team else {
            print("team is nil");
            return
        }
        
        nameText?.text = team.name
        UtilsController.shared.fetchImage(image: team.image) { (image) in
            if(image != nil){
                DispatchQueue.main.async {
                    self.photoCellImage.image = image
                }
            }
        }
    }
    
    // MARK: - IBAction
    @IBAction func saveTeamButtonTapped(_ sender: Any) {
        guard let image = photoCellImage.image, let nameText = nameText.text else {
            return
        }
        
        if let team = team {
            FirebaseManager.shared.updateTeam(team:team, name:nameText, image: image) { (success) in
                if(success) {
                    self.navigationController?.popViewController(animated: false)
                }
            }
        }
        else{
            FirebaseManager.shared.uploadTeam(name:nameText, image: image) { (success) in
                if(success) {
                    self.navigationController?.popViewController(animated: false)
                }
            }
        }
    }
}


extension TeamViewController: ProfileTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func selectPhotoButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Teams", message: "Select a photo", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                self.present(imagePickerController, animated:  true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionSheet.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (_) in
                imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePickerController, animated: true , completion: nil)
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoCellImage.image = photo
        }
    }
    
    
}
