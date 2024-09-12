//
//  TweetTableViewCell.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 2.09.2024.
//

import UIKit

protocol TweetTableViewCellDelegate: AnyObject {
    func didTapReply()
    func didTapRetweet()
    func didTapLike()
    func didTapShare()
}

class TweetTableViewCell: UITableViewCell {
    static let identifier = "TweetTableViewCell"
    
    weak var delegate: TweetTableViewCellDelegate?
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let displayNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Mehmet Ali Çelebi"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    let tweetTextContentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "This is my Mockup tweet, it is going to take multiple lines. i believe some more text is enough but I bla bla bla bla bla bla bla"
        label.numberOfLines = 0
        return label
    }()
    
    let replyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "replyIcon"), for: .normal)
        button.tintColor = .systemGray2
        return button
    }()
    
    let retweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "retweetIcon"), for: .normal)
        button.tintColor = .systemGray2
        return button
    }()
    
    let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "likeIcon"), for: .normal)
        button.tintColor = .systemGray2
        return button
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "shareIcon"), for: .normal)
        button.tintColor = .systemGray2
        return button
    }()
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addContentSubviews()
        configureConstraints()
        configureButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func addContentSubviews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(displayNameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(tweetTextContentLabel)
        contentView.addSubview(replyButton)
        contentView.addSubview(retweetButton)
        contentView.addSubview(likeButton)
        contentView.addSubview(shareButton)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            
            displayNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 20),
            displayNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            usernameLabel.leadingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor, constant: 10),
            usernameLabel.centerYAnchor.constraint(equalTo: displayNameLabel.centerYAnchor),
            
            tweetTextContentLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 20),
            tweetTextContentLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 10),
            tweetTextContentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            replyButton.leadingAnchor.constraint(equalTo: tweetTextContentLabel.leadingAnchor),
            replyButton.topAnchor.constraint(equalTo: tweetTextContentLabel.bottomAnchor, constant: 10),
            replyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            retweetButton.leadingAnchor.constraint(equalTo: replyButton.trailingAnchor, constant: 60),
            retweetButton.topAnchor.constraint(equalTo: replyButton.topAnchor),
            retweetButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            likeButton.leadingAnchor.constraint(equalTo: retweetButton.trailingAnchor, constant: 60),
            likeButton.topAnchor.constraint(equalTo: replyButton.topAnchor),
            likeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            shareButton.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 60),
            shareButton.topAnchor.constraint(equalTo: replyButton.topAnchor),
            shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
        ])
    }
    
    func configureButtons() {
        replyButton.addTarget(self, action: #selector(didTapReply), for: .touchUpInside)
        retweetButton.addTarget(self, action: #selector(didTapRetweet), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
    }
    
    func configureCell(with tweet: Tweet) {
        displayNameLabel.text = tweet.author.displayName
        usernameLabel.text = "@ \(tweet.author.username)"
        tweetTextContentLabel.text = tweet.tweetContent
        avatarImageView.kf.setImage(with: URL(string: tweet.author.avatarPath))
    }
    
    @objc func didTapReply() {
        delegate?.didTapReply()
    }
    
    @objc func didTapRetweet() {
        delegate?.didTapRetweet()
    }
    
    @objc func didTapLike() {
        delegate?.didTapLike()
    }
    
    @objc func didTapShare() {
        delegate?.didTapShare()
    }
}
