//
//  PostCell.swift
//  TheNews
//
//  Created by Luís Silva on 02/12/2020.
//

import UIKit

class PostCell: UITableViewCell {
    static let identifier = "PostCell"

    lazy var titleLabel: UILabel = UILabel()
    lazy var urlLabel: UILabel = UILabel()
    lazy var scoreLabel: UILabel = UILabel()
    lazy var commentCountLabel: UILabel = UILabel()
    lazy var dateLabel: UILabel = UILabel()

    private let verticalStackView: UIStackView = UIStackView()
    private let bottomStackView: UIStackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    private func commonInit() {
        bottomStackView.axis = .horizontal
        bottomStackView.spacing = 10
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomStackView)

        NSLayoutConstraint.activate([
            bottomStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            bottomStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bottomStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bottomStackView.heightAnchor.constraint(equalToConstant: 10)
        ])

        verticalStackView.spacing = 5
        verticalStackView.axis = .vertical
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(verticalStackView)

        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -15)
        ])

        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        verticalStackView.addArrangedSubview(titleLabel)

        urlLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        urlLabel.textColor = UIColor.gray
        verticalStackView.addArrangedSubview(urlLabel)

        scoreLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        bottomStackView.addArrangedSubview(scoreLabel)

        commentCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        bottomStackView.addArrangedSubview(commentCountLabel)

        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        bottomStackView.addArrangedSubview(dateLabel)

        bottomStackView.addArrangedSubview(UIView())
    }
}

extension PostCell {
    static var dateFormatter: RelativeDateTimeFormatter = {
        let df = RelativeDateTimeFormatter()
        df.unitsStyle = .abbreviated
        df.locale = Locale(identifier: "US")
        return df
    }()

    static func configureCell(_ cell: PostCell, post: Network.Model.Post) {
        cell.titleLabel.text = post.title
        cell.urlLabel.text = post.url.host ?? ""
        cell.scoreLabel.text = "⬆️ \(post.score)"
        cell.commentCountLabel.text = "💬 \(post.numberOfComments)"
        cell.dateLabel.text = "🕓 \(dateFormatter.localizedString(for: post.createdAt, relativeTo: Date()))"
    }
}

