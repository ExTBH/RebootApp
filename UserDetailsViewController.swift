//
//  UserDetailsViewController.swift
//  RebootApp
//
//  Created by Natheer on 30/01/2023.
//

import Foundation
import UIKit


final class UserDetailsViewController : UIViewController {
    private let userModel: UserModel
    private let tableView = UITableView(frame: CGRect(), style: .insetGrouped)
    
    init(userModel: UserModel) {
        self.userModel = userModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .init(named: "Secondary")
        navigationItem.largeTitleDisplayMode = .never
        title = userModel.full_name
        
        prepareTableView()
    }
    
    private func prepareTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorColor = .init(named: "AccentColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets()
                
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: super.view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.register(UserDetailsCell.self, forCellReuseIdentifier: "userDetailsCell")
        
        
    }
    
    
}

extension UserDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell = tableView.dequeueReusableCell(withIdentifier: "userDetailsCell", for: indexPath) as! UserDetailsCell

        
        switch indexPath.row {
        case 0:
            userCell.populate(with: "ID", value: String(userModel.id))
        case 1:
            userCell.populate(with: "Full Name", value: userModel.full_name)
        case 2:
            userCell.populate(with: "Username", value: userModel.login)
        case 3:
            userCell.populate(with: "Admin", value: userModel.is_admin ? "Yes" : "No")
        case 4:
            let dateString = UserDetailsCell.timeFormatter.string(from: userModel.created)
            userCell.populate(with: "Created", value: dateString)
        case 5:
            let dateString = UserDetailsCell.timeFormatter.string(from: userModel.last_login)
            userCell.populate(with: "Last Login(Broken)", value: dateString)
        case 6:
            userCell.populate(with: "Email", value: userModel.email, isURL: true, isMail: true)
        case 7:
            userCell.populate(with: "Website", value: userModel.website, isURL: true)
        case 8:
            userCell.populate(with: "Description", value: userModel.description)
        case 9:
            userCell.populate(with: "Location", value: userModel.location)
        case 10:
            userCell.populate(with: "Followers", value: String(userModel.followers_count))
        case 11:
            userCell.populate(with: "Following", value: String(userModel.following_count))
            
        default:
            break
        }
        
        
        return userCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCell = tableView.cellForRow(at: indexPath) as! UserDetailsCell
        
        guard let url = selectedCell.cellURL else { return }
        
        UIApplication.shared.open(url)
        
        
    }
    
    
}
