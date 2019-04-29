//
//  TeamViewController.swift
//  TeamsMembers
//
//  Created by Carlos Javier Pendola on 4/27/19.
//  Copyright © 2019 Carlos Javier Pendola. All rights reserved.
//

import UIKit

class TeamListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    var filteredTeams = [Team]()
    var team:Team?
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Teams"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        FirebaseManager.shared.fetchTeams { (success) in
            if(success){
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    // MARK: - TableviewFunctions
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredTeams.count
        }
        else{
            return FirebaseManager.shared.teams.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell", for: indexPath) as? TeamTableViewCell
        else {
            print("Unable to cast cell correctly.") ;
            return UITableViewCell()
        }
        
        var teamItem:Team
        if isFiltering() {
           teamItem = filteredTeams[indexPath.row]
        } else {
           teamItem = FirebaseManager.shared.teams[indexPath.row]
        }
    
        UtilsController.shared.fetchImage(image: teamItem.image) { (image) in
            DispatchQueue.main.async {
                cell.teamimageView?.image = image
            }
        }
        cell.team = teamItem
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            var teamItem:Team
            if self.isFiltering() {
                teamItem = self.filteredTeams[indexPath.row]
            } else {
                teamItem = FirebaseManager.shared.teams[indexPath.row]
            }
            FirebaseManager.shared.removeTeam(team: teamItem) { (success) in
                if(success){
                    if self.isFiltering() {
                        self.filteredTeams.remove(at: indexPath.row)
                    }
                    self.tableView.reloadData()
                }
            }
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            
            if self.isFiltering() {
                self.team = self.filteredTeams[indexPath.row]
            } else {
                self.team = FirebaseManager.shared.teams[indexPath.row]
            }
            self.performSegue(withIdentifier: "addEditTeam", sender: nil)
        }
        
        edit.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }
    
    // MARK: - Segue
    override func prepare(for segue:UIStoryboardSegue ,sender:Any?  ){
        if segue.identifier == "teamDetail"
        {
            print("teamDetail")
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destinationVC = segue.destination as? PlayerListViewController{
                    var teamItem:Team
                    if isFiltering() {
                        teamItem = filteredTeams[indexPath.row]
                    } else {
                        teamItem = FirebaseManager.shared.teams[indexPath.row]
                    }
                    destinationVC.team = teamItem
                }
            }
        }
        if segue.identifier == "addEditTeam"
        {
            if let destinationVC = segue.destination as? TeamViewController{
                destinationVC.team = team
            }
        }
    }
    
    // MARK: - Private instance methods
    func filterContentForSearchText(_ searchText: String) {
        filteredTeams = FirebaseManager.shared.teams.filter({ (team : Team) -> Bool in
            team.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}


extension TeamListViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}

extension TeamListViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
