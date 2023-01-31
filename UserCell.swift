//
//  UserCell.swift
//  RebootApp
//
//  Created by Natheer on 29/01/2023.
//

import UIKit

final class UserCell: UITableViewCell {
    static let timeFormatter: DateFormatter = {
        /// https://stackoverflow.com/a/42747959
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
        
    }()
    
    let avatar: UIImageView!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        if #available(iOS 14, *) {
            self.avatar =  UIImageView(image: .init(systemName: "person.fill.questionmark"))
        } else {
            self.avatar = UIImageView.init(image: .init(systemName: "person.badge.minus"))
        }
        self.avatar.translatesAutoresizingMaskIntoConstraints = false
        self.avatar.layer.cornerRadius = 10
        self.avatar.clipsToBounds = true
        
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.textLabel?.font = .boldSystemFont(ofSize: 17)
        self.textLabel?.adjustsFontSizeToFitWidth = true
        self.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
        let bgView = UIView()
        bgView.backgroundColor = .init(named: "AccentColor")
        self.selectedBackgroundView = bgView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func populate(with userModel: UserModel) {
        textLabel?.text = userModel.full_name
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel?.text = "Joined: \(UserCell.timeFormatter.string(from: userModel.created))"
        detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel?.textColor = .secondaryLabel
        
        backgroundColor = .clear
        accessoryType = .disclosureIndicator
        contentView.addSubview(avatar)
        
        NSLayoutConstraint.activate([
            avatar.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            avatar.safeAreaLayoutGuide.widthAnchor.constraint(equalToConstant: 35),
            avatar.safeAreaLayoutGuide.heightAnchor.constraint(equalToConstant: 35),
            avatar.safeAreaLayoutGuide.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor)

        ])
        
        NSLayoutConstraint.activate([
            textLabel!.safeAreaLayoutGuide.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 7),
            textLabel!.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: avatar.safeAreaLayoutGuide.trailingAnchor, constant: 10),
            textLabel!.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            detailTextLabel!.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            detailTextLabel!.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: avatar.safeAreaLayoutGuide.trailingAnchor, constant: 10),
            detailTextLabel!.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10)

        ])
        
        loadAvatar(with: userModel.avatar_url)
    }
    
    private func loadAvatar(with avatarURL: String){
        RBNetworking.shared.fetchImage(avatarURL, completion: {result in
            switch result {
                case .failure(_): break
                case .success(let image):
                    DispatchQueue.main.async { [weak self] in
                        self?.avatar.image = image
                }
            }
        })
    }
    
}
