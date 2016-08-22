//
//  JYStatusFPS.swift
//  JYStatusFPS
//
//  Created by 杨勇 on 16/8/19.
//  Copyright © 2016年 JackYang. All rights reserved.
//

import UIKit

public class JYStatusFPS: UIWindow {

    public static var shareInstance = JYStatusFPS()
    public var interval : Int = 5
    
    let historyLength: Int
    var fpsHistory:[Int] = []
    
    let fpsLayer = CAShapeLayer()
    let lbl : UILabel = UILabel()
    
    var internalCount: Int = 0
    
    lazy var displayLink: CADisplayLink = { //懒加载
        return CADisplayLink(target:self, selector:#selector(display))
    }()
    
    let fpsColor = UIColor (red: 1.0, green: 0.22, blue: 0.22, alpha: 1.0)
    let textColor = UIColor.grayColor()
    
    var lastTimestamp : CFTimeInterval = 0
    
    public static func start() {
        shareInstance.displayLink.paused = false
    }
    
     public static var transparent: Bool {
        get{
            return shareInstance.backgroundColor == UIColor.clearColor()
        }
        
        set(v){
            if v {
                shareInstance.backgroundColor = UIColor.clearColor()
            }
            else{
                shareInstance.backgroundColor = UIColor.lightGrayColor()
            }
        }
        
    }
    
    public static func stop() {
        shareInstance.displayLink.paused = true
        shareInstance.hidden = true
    }
    
    
    init(){
        let rc = UIApplication.sharedApplication().statusBarFrame
        historyLength = Int(rc.size.width)
        super.init(frame: rc)
        userInteractionEnabled = false
        
        windowLevel = UIWindowLevelStatusBar + 1
        backgroundColor = UIColor.lightGrayColor()
        
        fpsLayer.strokeColor = fpsColor.CGColor //边缘线颜色
        fpsLayer.fillColor = UIColor.clearColor().CGColor
        fpsLayer.drawsAsynchronously = true
        layer .addSublayer(fpsLayer)
        
        lbl.frame = bounds
        lbl.font = UIFont(name:"Courier", size: 11)
        lbl.textColor = UIColor.grayColor()
        lbl.adjustsFontSizeToFitWidth = true
        lbl.textAlignment = .Center
        addSubview(lbl)
        
        displayLink.paused = true
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(notifyActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(notifyDeactive), name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func notifyActive() {
        displayLink.paused = false
        lastTimestamp = 0
    }
    
    func notifyDeactive() {
        displayLink.paused = true
    }
    
    
    func display() {
        if lastTimestamp == 0 { //第一次
            lastTimestamp = displayLink.timestamp
            return
        }
        
        let duration = displayLink.duration //时间间隔
        if duration == 0 { return }
        
        if hidden && UIApplication.sharedApplication().keyWindow != nil { hidden = false} //等待 keywindow 设置完成
        
        if fpsHistory.count > historyLength { fpsHistory.removeAtIndex(0) } // 每帧一个point 当 需要 绘制的 数量大于 宽度，删除第一个（即最早的那个）
        let timestamp = (displayLink.timestamp - lastTimestamp)/duration
        let fps = Int(round(timestamp))//当前
        fpsHistory.append(fps) //添加到fps 数组 等待 绘制
        lastTimestamp = displayLink.timestamp
        
        
        //次数限制 统计五次 绘制一次
        internalCount += 1
        if internalCount < interval { return }
        internalCount = 0
        
        let fpspath = UIBezierPath() //贝塞尔曲线  结合 shapeLayer 画出曲线
        
        var x : CGFloat = 0
        var drop : Int = 0
        var totalfc : Int = 0
        for v in fpsHistory {
            totalfc += v
            drop = max(drop, v-1)
            let y:CGFloat = min(bounds.size.height - 1,CGFloat((v - 1) * 5 + 1))
            if x == 0.0 { fpspath.moveToPoint(CGPoint(x: 0, y: y)) }
            fpspath.addLineToPoint(CGPoint(x: x, y: y))
            x += 1.0 //后移一个像素
        }
        
        fpsLayer.path = fpspath.CGPath
        
        var avg = 0
        if totalfc > 0 { avg = Int(round(1.0 / duration)) * fpsHistory.count / totalfc }
        lbl.text = String(format: "%d fps ",avg)
    }
    

}
