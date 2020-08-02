//
//  ChatBubbleView.swift
//  Pointters
//
//  Created by Mac on 1/1/18.
//  Copyright © 2018 Simran. All rights reserved.
//

import UIKit

class ChatBubbleView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var ivBgBubble: UIImageView!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var leadingSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingSpacingConstraint: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupComponents()
    }
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        setupComponents()
    }
    
    func setupComponents() {
        Bundle.main.loadNibNamed("ChatBubbleView", owner: self, options: nil)
        addSubview(self.contentView)
        self.contentView.frame = self.bounds

        self.ivBgBubble.translatesAutoresizingMaskIntoConstraints = false
        self.lblText.translatesAutoresizingMaskIntoConstraints = false
        
        self.lblText.numberOfLines = 0
        self.lblText.lineBreakMode = .byWordWrapping
        self.lblText.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - 130
    }
    
    override var intrinsicContentSize: CGSize {
        let textSize:CGSize = self.lblText.intrinsicContentSize
        return CGSize(width:textSize.width + 30, height:textSize.height + 16.0)
    }
    
    func setText(contentText:String, nBubble:Bool) {
        self.lblText.font = UIFont(name: "Helvetica", size: 15)!
        
        var imageName = ""
        if nBubble {
            self.lblText.textColor = UIColor.darkGray
            self.leadingSpacingConstraint.constant = 10//20.0
            self.trailingSpacingConstraint.constant = 10.0
            imageName = "bg_chat_msg_gray"
            self.ivBgBubble.image = UIImage(named:imageName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(13, 13, 13, 36))
        }
        else {
            self.lblText.textColor = UIColor.white
            self.leadingSpacingConstraint.constant = 10.0
            self.trailingSpacingConstraint.constant = 20.0
            imageName = "bg_chat_msg"
            self.ivBgBubble.image = UIImage(named:imageName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(13, 13, 13, 36))
        }
        
        self.lblText.text = contentText
        self.invalidateIntrinsicContentSize()
        self.setNeedsDisplay()
    }
}
