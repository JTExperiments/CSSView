//
//  SwiftReactive.swift
//  SwiftReactiveDemo
//
//  Created by Simon Pang on 29/10/14.
//  Copyright (c) 2014 Simon. All rights reserved.
//

import UIKit

import ObjectiveC

var AssociatedObjectHandle: UInt8 = 0

extension NSObject {
    var reactiveBinding:AnyObject {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
}

@objc class ReactiveObject : NSObject {
    var source : NSObject

    init(_ source : NSObject) {
        self.source = source
        super.init()
        self.source.reactiveBinding = self // self retain
    }
    
    func string(keyPath: String, channel : ObservableReference<String>) -> ReactiveObject {
        self.source.setValue(channel.value, forKeyPath: keyPath)
        channel.afterChange.add(owner: self) {
            change in
            self.source.setValue(change.newValue, forKeyPath: keyPath)
        }
        return self
    }
    
    func object(keyPath: String, channel : ObservableReference<AnyObject>) -> ReactiveObject {
        self.source.setValue(channel.value, forKeyPath: keyPath)
        channel.afterChange.add(owner: self) {
            change in
            self.source.setValue(change.newValue, forKeyPath: keyPath)
        }
        return self
    }
    
    func bool(keyPath: String, channel : ObservableReference<Bool>) -> ReactiveObject {
        self.source.setValue(channel.value, forKeyPath: keyPath)
        channel.afterChange.add(owner: self) {
            change in
            self.source.setValue(change.newValue, forKeyPath: keyPath)
        }
        return self
    }
}

class View : ReactiveObject {
    var view : UIView {
        return self.source as UIView
    }
    
    override init(_ view : NSObject) {
        super.init(view)
    }
    
    func hidden(boolChannel : ObservableReference<Bool>) -> View {
        self.view.hidden = boolChannel.value
        boolChannel.afterChange.add(owner: self) {
            change in
            self.view.hidden = change.newValue
        }
        return self
    }

    func css(stringChannel : ObservableReference<String>) -> View {
        self.styleCSS = stringChannel.value
        stringChannel.afterChange.add(owner: self) {
            change in
            self.styleCSS = change.newValue
        }
        return self
    }

    var styleCSS : String {
        get {
            return self.view.styleCSS ?? ""
        }
        set {
            self.view.styleCSS = newValue
            println("cssStyle <- \(newValue)")
        }
    }
    
    func updateCss(name: String, flag:Bool) {
        if flag {
            // Append
            var classes = self.styleCSS.componentsSeparatedByString(" ")
            if find(classes, name) == nil {
                classes.append(name)
                self.styleCSS = join(" ", classes)
            }
        }
        else {
            // Remove
            var classes = self.styleCSS.componentsSeparatedByString(" ")
            if let index = find(classes, name) {
                classes.removeAtIndex(index)
                self.styleCSS = join(" ", classes)
            }
        }
    }
    
    func css(name:String, channel : ObservableReference<Bool>) -> View {
        updateCss(name, flag: channel.value)
        channel.afterChange.add(owner: self) {
            change in
            self.updateCss(name, flag: change.newValue)
        }
        return self
    }
}

class Label : View {
    
    var label : UILabel {
        return super.view as UILabel
    }

    override init(_ label : NSObject) {
        super.init(label as UILabel)
    }
        
    func text(stringChannel: ObservableReference<String>) -> Label {
        self.string("text", channel: stringChannel)
        return self
    }
}


class TextField : View {
    
    var textField : UITextField {
        return super.view as UITextField
    }
    var textChannel : ObservableReference<String>?
    
    override init(_ textField : NSObject) {
        super.init(textField as UITextField)
    }
    
    func bind(channel : ObservableReference<String>) -> TextField {
        self.textField.addTarget(self, action: "valueDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.textChannel = channel
        return self
    }
    
    func valueDidChange(sender: UITextField) {
        self.textChannel?.value = self.textField.text
    }
    
}

class Button : View {
    
    var button : UIButton {
        return self.view as UIButton
    }
    var channel : ObservableReference<()>?
    var callback : (()->())?
    
    override init(_ button : NSObject) {
        super.init(button as UIButton)
        self.button.addTarget(self, action: "touchUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func bind(channel : ObservableReference<()>) -> Button {
        self.channel = channel
        return self
    }
    
    func bind(callback: () -> ()) -> Button {
        self.callback = callback
        return self
    }
    
    func enabled(boolChannel : ObservableReference<Bool>) -> Button {
        self.bool("enabled", channel: boolChannel)
        return self
    }
    
    func title(stringChannel: ObservableReference<String>) -> Button {
        self.string("title", channel: stringChannel)
        return self
    }
    
    func touchUpInside(sender: UIButton) {
        self.channel?.value = ()
        self.callback?()
    }
    
}

class BarButtonItem : ReactiveObject {
    
    var barButtonItem : UIBarButtonItem {
        return self.source as UIBarButtonItem
    }
    
    var callback : (()->())?
    
    override init(_ button : NSObject) {
        super.init(button as UIBarButtonItem)
        self.barButtonItem.target = self
        self.barButtonItem.action = "didPress"
    }

    func didPress() {
        self.callback?()
    }
    
    func bind(callback: () -> ()) -> BarButtonItem {
        self.callback = callback
        return self
    }
    
    func enabled(boolChannel : ObservableReference<Bool>) -> BarButtonItem {
        self.bool("enabled", channel: boolChannel)
        return self
    }
    
    func title(stringChannel: ObservableReference<String>) -> BarButtonItem {
        self.string("title", channel: stringChannel)
        return self
    }
    
}

class TableView : View, UITableViewDataSource, UITableViewDelegate  {
    
    typealias ValueType = AnyObject
    
    var objects = [ValueType]()
    var registeredCells = [Cell]()
    
    var tableView : UITableView {
        return self.view as UITableView
    }
    
    override init(_ tableView : NSObject) {
        super.init(tableView as UITableView)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func items(items : ObservableReference<[ValueType]>) -> TableView {
        items.afterChange.add {
            change in
            self.objects = change.newValue
            self.tableView.reloadData()
        }
        return self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var item : ValueType = self.objects[indexPath.row]
        
        for candidateCell in self.registeredCells {
            if candidateCell.predicate(item) {
                var cell = tableView.dequeueReusableCellWithIdentifier(candidateCell.identifier, forIndexPath: indexPath) as UITableViewCell
                candidateCell.bindingHandler(item, cell)
                return cell
            }
        }
        abort()
    }
    
    
    func registerCell(cell:Cell) {
        self.registeredCells.append(cell)
    }
}

class Cell {
    
    typealias ValueType = AnyObject
    
    var identifier : String
    var predicate : (ValueType->Bool)!
    var bindingHandler : ((ValueType,UITableViewCell)->())!
    
    
    init(_ tableView: TableView, identifier : String) {
        self.identifier = identifier
        tableView.registerCell(self)
    }
    
    func filter(predicate: ValueType->Bool) -> Cell {
        self.predicate = predicate
        return self
    }
    
    func bind(handler: (ValueType,UITableViewCell)->()) {
        self.bindingHandler = handler
    }
    
}

