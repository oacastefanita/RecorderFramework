//
//  WaveHolderView.swift
//  Recorder
//
//  Created by Grif on 11/05/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation

protocol WaveHolderViewDelegate{
    func cursorMoved()
}


class WaveHolderView : UIView
{
    var cursor:UIImageView!
    var scrollView:UIScrollView!
    var maxXPosition:Int = 0
    
    var timer:Timer!
    var moveDirection:Float = 0
    
    var movingCursor=false
    
    var delegate:WaveHolderViewDelegate!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        movingCursor = true
        let touch = touches.first
        
        self.cursor.frame = CGRect(x:touch!.location(in: self).x - self.cursor.frame.width / 2, y:self.cursor.frame.origin.y, width: self.cursor.frame.size.width, height: self.cursor.frame.size.height)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first
        
        self.cursor.frame = CGRect(x: touch!.location(in: self).x - self.cursor.frame.width / 2, y: self.cursor.frame.origin.y, width: self.cursor.frame.size.width, height: self.cursor.frame.size.height)
        
        if self.cursor.frame.origin.x < 60 {
            moveDirection = -0.5
            if self.cursor.frame.origin.x < 20 {
                moveDirection = -2.0
            }
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(WaveHolderView.updateScrollViewContent), userInfo: nil, repeats: true)
            }
        }
        else if self.cursor.frame.origin.x + self.cursor.frame.width / 2 > self.frame.size.width - 60 {
            moveDirection = 0.5
            if self.cursor.frame.origin.x + self.cursor.frame.width / 2 > self.frame.size.width - 20 {
                moveDirection = 2.0
            }

            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(WaveHolderView.updateScrollViewContent), userInfo: nil, repeats: true)
            }
        }
        else {
            moveDirection = 0
            if timer != nil {
                timer.invalidate()
                timer = nil
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveDirection = 0
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        if delegate != nil {
            delegate.cursorMoved()
        }
        movingCursor = false
    }
    
    @objc func updateScrollViewContent() {
        if moveDirection > 0 {
            if Int(scrollView.contentOffset.x + self.frame.size.width / 2) < maxXPosition {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x + CGFloat(moveDirection),y: 0)
            }
            else {
                scrollView.contentOffset = CGPoint(x: CGFloat(maxXPosition) - self.frame.size.width / 2,y: 0)
            }
        }
        else if scrollView.contentOffset.x > 5  {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x + CGFloat(moveDirection),y: 0)
        }
    }
    
}
