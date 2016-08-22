//
//  ViewController.swift
//  JYStatusFPS
//
//  Created by 杨勇 on 16/8/17.
//  Copyright © 2016年 JackYang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let button = currying()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.setTarget(self, action: ViewController.onButtonTap, controlEvent: .TouchUpInside)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onButtonTap(){
        
       
        
    }
    
    
    
}



/// 目标事件协议

protocol TargetAction {
    
    func performAction()
    
}


/**
 
 OC中的委托
 
 事件包装结构,这里是泛型,这里表示传入的数据类型可以是AnyObject
 
 这个方法遵循TargetAction协议来处理事件
 
 */

struct TargetActionWrapper<T: AnyObject>:TargetAction{
    
    
    
    weak var target: T?
    
    let action: (T) -> () -> ()
    
    
    
    func performAction() -> () {
        
        if let t = target {
            
            action(t)()
            
        }
        
    }
    
}


/// 枚举事件

enum ControlEvent {
    
    case TouchUpInside
    
    case ValueChanged
    
    //...
    
}


/// 例子

class currying{
    var actions = [ControlEvent :TargetAction]()
    
    func setTarget<T:AnyObject>(target: T,action: (T) -> () -> (),controlEvent:ControlEvent){
        
        actions[controlEvent] = TargetActionWrapper(target:target,action:action)
        print(T)
        print(action)
    }
    
    
    
    
    
    /// 移除
    
    func removeTargetForControlEvent(controlEvent:ControlEvent){
        
        actions[controlEvent] = nil
        
    }
    
    
    
    /// 执行
    
    func performActionForControlEvent(controlEvent:ControlEvent){
        
        actions[controlEvent]?.performAction()
        
    }
    
}
