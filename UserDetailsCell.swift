//
//  UserDetailsCell.swift
//  RebootApp
//
//  Created by Natheer on 31/01/2023.
//

import UIKit


final class UserDetailsCell: UITableViewCell {
    static let timeFormatter: DateFormatter = {
        /// https://stackoverflow.com/a/42747959
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
        
    }()
    
    var cellURL: URL?
    
    
    
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            textLabel?.font = .boldSystemFont(ofSize: 17)
            textLabel?.adjustsFontSizeToFitWidth = true

        backgroundColor = .clear

        let bgView = UIView()
        bgView.backgroundColor = .init(named: "AccentColor")
        self.selectedBackgroundView = bgView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func populate(with key: String, value: String, isURL: Bool = false, isMail: Bool = false) {
        selectionStyle = .none
        
        if isURL { populateURL(with: value, isMail: isMail) }
        let nilCheckedValue = value == "" ? "None" : value
        let attributedDetail = NSMutableAttributedString(string: "\(key): \(nilCheckedValue)")
        
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 15)
        
        ]
        
        attributedDetail.addAttributes(valueAttrs, range: NSRange(location: key.count+2, length: nilCheckedValue.count))
        
        
        textLabel?.attributedText = attributedDetail
        

    }
    
    private func populateURL(with value: String, isMail: Bool) {
        if isMail {
            cellURL = URL(string: "mailto:\(value)")
        } else {
            cellURL = URL(string: value)
        }
        if cellURL != nil {
            self.accessoryType = .disclosureIndicator
            selectionStyle = .default
        }
        
        
    }

    
}
