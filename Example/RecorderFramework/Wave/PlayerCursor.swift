//
//  PlayerCursor.swift
//  Recorder
//
//  Created by Grif on 14/02/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation

class PlayerCursor : UIView {
    
    var lblValue:UILabel!
    
    var valueView:UIView!
    var cursorImage:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let frame = CGRect(x: 0, y: 0, width: frame.width, height: 24)
        
        lblValue = UILabel(frame: CGRect(x: 0, y: -2, width: frame.width, height: frame.height-3))
        lblValue.backgroundColor = UIColor.clear
        lblValue.textColor = UIColor.white
        lblValue.textAlignment = NSTextAlignment.center
        lblValue.font = UIFont.systemFont(ofSize: 13)
        
        
        valueView = UIView(frame: frame)
        valueView.backgroundColor = UIColor(red: 239/255, green: 52/255, blue: 52/255, alpha: 1)
        let clippingPath = UIBezierPath()
        clippingPath.move(to: CGPoint(x:0,y:4))
        clippingPath.addCurve(to: CGPoint(x: 4, y: 0), controlPoint1: CGPoint(x: 0, y: 0), controlPoint2: CGPoint(x: 0, y: 0))
        clippingPath.addLine(to: CGPoint(x: frame.width-4, y: 0))
        clippingPath.addCurve(to: CGPoint(x: frame.width, y: 4), controlPoint1: CGPoint(x: frame.width, y: 0), controlPoint2: CGPoint(x: frame.width, y: 0))
        clippingPath.addLine(to: CGPoint(x: frame.width, y: frame.height - 9))
        clippingPath.addCurve(to: CGPoint(x: frame.width-4, y: frame.height-5), controlPoint1: CGPoint(x: frame.width, y: frame.height-5), controlPoint2: CGPoint(x: frame.width, y: frame.height-5))
        
        clippingPath.addLine(to: CGPoint(x: frame.width/2 + 3, y: frame.height - 5))
        clippingPath.addLine(to: CGPoint(x: frame.width/2 - 1, y: frame.height))
        clippingPath.addLine(to: CGPoint(x: frame.width/2 - 5, y: frame.height - 5))
        clippingPath.addLine(to: CGPoint(x: 4, y: frame.height - 5))
        
        clippingPath.addCurve(to: CGPoint(x: 0, y: frame.height-9), controlPoint1: CGPoint(x: 0, y: frame.height-5), controlPoint2: CGPoint(x: 0, y: frame.height-5))
        clippingPath.close()
        
        let mask = CAShapeLayer()
        mask.path = clippingPath.cgPath
        valueView.layer.mask = mask;
        
        valueView.addSubview(lblValue)
        
        self.addSubview(valueView)
        
        self.backgroundColor = UIColor.clear
        
        cursorImage = UIImageView(frame: CGRect(x: (self.frame.width - 7) / 2, y: 26, width: 6, height: self.frame.height - 24))
        cursorImage.image = UIImage(named: "cursor")
        self.addSubview(cursorImage)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
