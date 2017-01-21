//
//  StatusMesssageView.swift
//  Sense
//
//  Created by Jimmy Lu on 1/20/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

@objc class StatusMesssageView: UIView {
    
    static let textHorzMargin = CGFloat(30.0)
    static let imageHeight = CGFloat(80.0)
    static let spacingBetweenText = CGFloat(8.0)
    static let imageTopMargin = CGFloat(56.0)
    static let titleTopMargin = CGFloat(32.0)
    static let messageBotMargin = CGFloat(24.0)
    
    @objc @IBOutlet weak var imageView: UIImageView!
    @objc @IBOutlet weak var titleLabel: UILabel!
    @objc @IBOutlet weak var messageLabel: UILabel!
    
    fileprivate var image: UIImage?
    fileprivate var title: String?
    fileprivate var message: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    convenience init(width: CGFloat,
                     image: UIImage,
                     title: String,
                     message: String) {
        let textMaxWidth = width - (StatusMesssageView.textHorzMargin * 2)
        let titleHeight = title.heightBounded(byWidth: textMaxWidth,
                                              using: UIFont.h5())
        let messageHeight = message.heightBounded(byWidth: textMaxWidth,
                                                  using: UIFont.body())
        let totalHeight = StatusMesssageView.imageTopMargin
            + StatusMesssageView.imageHeight
            + StatusMesssageView.titleTopMargin
            + titleHeight
            + StatusMesssageView.spacingBetweenText
            + messageHeight
            + StatusMesssageView.messageBotMargin
        
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: width, height: totalHeight))
        
        self.init(frame: frame)
        
        self.image = image
        self.title = title
        self.message = message
        self.configureContent()
    }
    
    // MARK: - Manual allocation of subviews
    
    fileprivate func configureContent() {
        guard self.imageView == nil && titleLabel == nil && messageLabel == nil else {
            return
        }
        
        let imageFrame = self.addImageView()
        let titleFrame = self.addTitleLabel(imageFrame: imageFrame)
        let _ = self.addMessageLabel(titleFrame: titleFrame)
    }
    
    fileprivate func addImageView() -> CGRect {
        guard self.imageView == nil else {
            return self.imageView.frame
        }
        
        guard let image = self.image else {
            return CGRect.zero
        }
        
        let imageFrame = CGRect(x: CGFloat(0),
                                y: StatusMesssageView.imageTopMargin,
                                width: self.bounds.size.width,
                                height: StatusMesssageView.imageHeight)
        let imageView = UIImageView(image: image)
        imageView.frame = imageFrame
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(imageView)
        self.imageView = imageView
        return imageFrame
    }
    
    fileprivate func addTitleLabel(imageFrame: CGRect) -> CGRect {
        guard self.titleLabel == nil else {
            return self.titleLabel.frame
        }
        
        guard let title = self.title else {
            return CGRect.zero
        }
        
        let textWidth = self.bounds.size.width - (StatusMesssageView.textHorzMargin * 2)
        let titleHeight = title.heightBounded(byWidth: textWidth,
                                              using: UIFont.h5())
        let titleY = imageFrame.origin.y + imageFrame.size.height + StatusMesssageView.titleTopMargin
        let titleFrame = CGRect(x: StatusMesssageView.textHorzMargin,
                                y: titleY,
                                width: textWidth,
                                height: titleHeight)
        let titleLabel = UILabel(frame: titleFrame)
        titleLabel.font = UIFont.h5()
        titleLabel.text = title
        titleLabel.textColor = UIColor.grey6()
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.translatesAutoresizingMaskIntoConstraints = true
        titleLabel.numberOfLines = 0
        self.addSubview(titleLabel)
        self.titleLabel = titleLabel
        return titleFrame
    }
    
    fileprivate func addMessageLabel(titleFrame: CGRect) -> CGRect {
        guard self.messageLabel == nil else {
            return self.messageLabel.frame
        }
        
        guard let message = self.message else {
            return CGRect.zero
        }
        
        let paragraphStyle = DefaultBodyParagraphStyle()!
        paragraphStyle.alignment = NSTextAlignment.center
        let messageAttributes: [String : Any] = [NSFontAttributeName : UIFont.body(),
                                                NSForegroundColorAttributeName : UIColor.grey5(),
                                                NSParagraphStyleAttributeName : paragraphStyle];
        let attributedMessage = NSAttributedString(string: message, attributes: messageAttributes)
        let textWidth = self.bounds.size.width - (StatusMesssageView.textHorzMargin * 2)
        let messageHeight = attributedMessage.size(withWidth: textWidth).height
        let messageY = titleFrame.origin.y + titleFrame.size.height + StatusMesssageView.spacingBetweenText
        let messageFrame = CGRect(x: StatusMesssageView.textHorzMargin,
                                  y: messageY,
                                  width: textWidth,
                                  height: messageHeight)
        let messageLabel = UILabel(frame: messageFrame)
        messageLabel.font = UIFont.body()
        messageLabel.attributedText = attributedMessage
        messageLabel.textColor = UIColor.grey5()
        messageLabel.textAlignment = NSTextAlignment.center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(messageLabel)
        self.messageLabel = messageLabel
        return messageFrame
    }
    
}
