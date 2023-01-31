//
//  ViewController.swift
//  RebootApp
//
//  Created by Natheer on 28/01/2023.
//

import UIKit

class ViewController: UIViewController {
    private let tableView = UITableView(frame: CGRect(), style: .insetGrouped)
    
    private var users: [UserModel]?
    
    private var filteredUsers: [UserModel]?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareNavBar()
        prepareTableView()
        updateData()
        
    }
    
    private func prepareNavBar() {
        title = "Reboot Students"
        view.backgroundColor = .init(named: "Secondary")
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let filterButton: UIBarButtonItem = UIBarButtonItem(image: .init(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: nil, action: nil)
        if #available(iOS 14, *) {
            filterButton.menu = UIMenu(title: "Sort By", children: filterMenuProvider())
        }
        navigationItem.rightBarButtonItem = filterButton
        
    }
    
    private func prepareTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorColor = .init(named: "AccentColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshedTable), for: .valueChanged)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: super.view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "userCell")
        
        
    }
    
    private func updateData(completion: ((Bool) -> Void)? = nil) {
        RBNetworking.shared.fetchUsers({ [weak self] result in
            switch result {
                case .failure(let error):
                    print("Got Error \(error)")
                guard completion == nil else {
                    completion!(false)
                    return
                }
            case .success(let usersResult):
                guard let self = self else { return }
                self.users = usersResult
                DispatchQueue.main.async {
                    if let completion = completion { completion(true) }
                    self.tableView.reloadSections([0], with: .automatic)
                }
            }
        })
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let filteredUsers = filteredUsers else {
            guard let users = users else { return 0 }
            return users.count
        }
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
                
        let userModel: UserModel
        
        if filteredUsers != nil {
            userModel = filteredUsers![indexPath.row]
        }
        else {
            userModel = users![indexPath.row]
        }
        
        userCell.populate(with: userModel)

        return userCell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tappedModel: UserModel!
        if filteredUsers != nil {
            tappedModel = filteredUsers![indexPath.row]
        } else {
            tappedModel = users![indexPath.row]
        }
        
        let userView = UserDetailsViewController(userModel: tappedModel)
        self.navigationController?.pushViewController(userView, animated: true)
    }
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let users = users else { return nil }
        
        return "Total Students: \(users.count)"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let footer = """
Data is publicly accessible through Reboot's Gitea Instance, Logos and Colors are property of Reboot
Source Code can be found at github.com/ExTBH/RebootApp
"""
        return footer
    }
    
}

extension ViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredUsers = nil
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let users = users else { return }            
        filteredUsers = users.filter {
            $0.full_name.range(of: searchText, options: .caseInsensitive) != nil
        }
        tableView.reloadData()
    }
    
}


extension ViewController {
    private class func animatedRefresh(for tableView: UITableView) {
        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
        
        DispatchQueue.main.async {
            tableView.reloadRows(at: indexPaths, with: .left)
        }
        
    }
    
    
    /// https://www.agnosticdev.com/content/how-sort-objects-date-swift
    private func filterMenuProvider() -> [UIAction]{
        let alpha = UIAction(title: "Alphabetical") { [weak self](_) in
            guard let self = self else { return }
            
            self.filteredUsers = nil
            ViewController.animatedRefresh(for: self.tableView)
        }
        let newest = UIAction(title: "Newest") { [weak self] (_) in
            guard let self = self else { return }
            guard let users = self.users else { return }
            
            self.filteredUsers = users.sorted() {
                $0.created.compare($1.created) == .orderedDescending
            }
            ViewController.animatedRefresh(for: self.tableView)
            
        }
        let oldest = UIAction(title: "Oldest") { [weak self] (_) in
            guard let self = self else { return }
            guard let users = self.users else { return }
            
            self.filteredUsers = users.sorted() {
                $0.created.compare($1.created) == .orderedAscending
            }
            ViewController.animatedRefresh(for: self.tableView)
            
        }
        
        return [alpha, newest, oldest]
    }
    
    
    @objc private func refreshedTable(sender: UIRefreshControl){
        if self.filteredUsers != nil {
            sender.endRefreshing()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            
            self.updateData() { isSuccess in
                if isSuccess {
                    DispatchQueue.main.async {
                        self.tableView.refreshControl?.endRefreshing()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: "Failed to Refresh", message: nil, preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                        alert.addAction(cancel)
                        self.present(alert, animated: true)
                        self.tableView.refreshControl?.endRefreshing()
                    }
                }
            }
        }
    }
}
