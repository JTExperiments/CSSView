//
//  SwiftReactiveUtils.swift
//  CSSView
//
//  Created by Simon Pang on 30/10/14.
//  Copyright (c) 2014 Simon. All rights reserved.
//

import UIKit
extension ObservableReference {
    
    func map<E> (handler: T->E) -> ObservableReference<E> {
        
        var initValue = handler(self.value)
        var channel = ObservableReference<E>(initValue)
        
        self.afterChange.add {
            change -> () in
            var newValue = handler(change.newValue)
            
            channel.value = newValue
            return
        }
        
        return channel
    }
    
    func filter(predicate: T->Bool) -> ObservableReference<T> {
        
        var channel = ObservableReference<T>(self.value)
        
        self.afterChange.add {
            change -> () in
            if  predicate(change.newValue) {
                channel.value = change.newValue
            }
            return
        }
        
        return channel
    }

}

public func &&(lhs: ObservableReference<Bool>, rhs:ObservableReference<Bool>) -> ObservableReference<Bool> {
    var channel = ObservableReference<Bool>(lhs.value && rhs.value)
    
    lhs.afterChange.add {
        change in
        channel.value = change.newValue && rhs.value
    }
    rhs.afterChange.add {
        change in
        channel.value = change.newValue && lhs.value
    }
    return channel
}

public class Scheduler : NSObject {
    public var timer : NSTimer?
    var handler : (Void->Void)?
    
    public override init() {
        super.init()
    }
    
    public func schedule(interval: NSTimeInterval, handler:(Void->Void)) {
        self.handler = handler
        self.timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "timerDidFire:", userInfo: nil, repeats: true)
    }
    public func timerDidFire(timer: NSTimer) {
        if let handler = handler {
            handler()
        }
    }
    public func invalidate() {
        if let timer = timer {
            if timer.valid {
                timer.invalidate()
            }
        }
        timer = nil
    }
}


func delay(seconds:NSTimeInterval, handler:() -> ()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(seconds * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), {
            handler()
    })
}