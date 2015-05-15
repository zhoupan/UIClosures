//
//  ArkUI.swift
//  
//
//  Created by Zaid on 5/13/15.
//
//

import Foundation
import UIKit

public enum AUIControlEvent: UInt {
    case TouchDown = 1
    case TouchDownRepeat = 2
    case TouchDragInside = 4
    case TouchDragOutside = 8
    case TouchDragEnter = 16
    case TouchDragExit = 32
    case TouchUpInside = 64
    case TouchUpOutside = 128
    case TouchCancel = 256
    
    case ValueChanged = 4096
    
    case EditingDidBegin = 65536
    case EditingChanged = 131072
    case EditingDidEnd = 262144
    case EditingDidEndOnExit = 524288
    
    case AllTouchEvents = 0x00000FFF
    case AllEditingEvents = 0x000F0000
    case ApplicationReserved = 0x0F000000
    case SystemReserved = 0xF0000000
    case AllEvents = 0xFFFFFFFF
    
    public static func auiEventsFromUI(events: UIControlEvents) -> [AUIControlEvent] {
        var evs = [AUIControlEvent]()
        let ev = events.rawValue
        let one: UInt = 1
        for i: UInt in 0..<20 {
            let it = one << i
            if (it & ev) > 0 {
                if let auievent = AUIControlEvent(rawValue: it) {
                    evs.append(auievent)
                }
            }
        }
        return evs
    }
}

public class ArkUI {
    static let instance = ArkUI()
    static var listeners = Dictionary<WeakKey<UIView>,[AUIControlEvent:Array<(sender: AnyObject) -> ()>]>()
    static func addListener(view: UIView, events: [AUIControlEvent], listener: (sender: AnyObject) -> ()) {
        WeakCollections.clean(&listeners)
        let viewKey = WeakCollections.weakKeyOrNew(view, dict:listeners)
        var viewListeners = listeners[viewKey]
        if viewListeners == nil {
            viewListeners = [AUIControlEvent:Array<(sender: AnyObject) -> ()>]()
            listeners[viewKey] = viewListeners!
        }
        var lists = viewListeners!
        for event in events {
            var evlist = lists[event]
            if evlist == nil {
                evlist = Array<(sender:AnyObject) -> ()>()
                lists[event] = evlist!
            }
            evlist!.append(listener)
            lists[event] = evlist!
        }
        listeners[viewKey] = lists
    }
    static func removeListener(view: UIView, events: [AUIControlEvent], listener: (sender: AnyObject) -> ()) {
        WeakCollections.clean(&listeners)
        if let viewKey = WeakCollections.weakKey(view, dictionary: listeners) {
            var viewListeners = listeners[viewKey]!
            for event in events {
                if var evlisteners = viewListeners[event] {
                    var indexForRemove = -1
                    for (index, list) in enumerate(evlisteners) {
                        let listfix = list as (sender: AnyObject) -> ()
                        if listfix === listener {
                            indexForRemove = index
                        }
                    }
                    if indexForRemove > -1 {
                        let r = evlisteners.removeAtIndex(indexForRemove)
                        viewListeners[event] = evlisteners
                    }
                }
            }
        }
    }
    
    static func addTargetIfNeeded(view: UIControl, event: UIControlEvents) {
        WeakCollections.clean(&listeners)
        let events = AUIControlEvent.auiEventsFromUI(event)
        for ev in events {
            if let viewKey = WeakCollections.weakKey(view, dictionary: listeners) {
                let viewlisteners = listeners[viewKey]!
                if let evlisteners = viewlisteners[ev] {
                    
                } else {
                    view.addTarget(self, action: self.selector(ev), forControlEvents: UIControlEvents(ev.rawValue))
                }
            } else {
                view.addTarget(self, action:self.selector(ev), forControlEvents: UIControlEvents(ev.rawValue))
            }
        }
    }
    
    static func handleEvent(event: AUIControlEvent, sender: UIView) {
        WeakCollections.clean(&listeners)
        if let lists = WeakCollections.valueForWeakKey(sender, dict: listeners) {
            if let evlisteners = lists[event] {
                for listener in evlisteners {
                    listener(sender: sender)
                }
            }
        }
    }
    
    static var gestureListeners = Dictionary<WeakKey<UIGestureRecognizer>,Array<(gestureRecognizer: UIGestureRecognizer) -> ()>>()
    static var longPressListeners = Dictionary<WeakKey<UILongPressGestureRecognizer>,Array<(gestureRecognizer: UILongPressGestureRecognizer) -> ()>>()
    static var panListeners = Dictionary<WeakKey<UIPanGestureRecognizer>,Array<(gestureRecognizer: UIPanGestureRecognizer) -> ()>>()
    static var pinchListeners = Dictionary<WeakKey<UIPinchGestureRecognizer>,Array<(gestureRecognizer: UIPinchGestureRecognizer) -> ()>>()
    static var rotationListeners = Dictionary<WeakKey<UIRotationGestureRecognizer>,Array<(gestureRecognizer: UIRotationGestureRecognizer) -> ()>>()
    static var swipeListeners = Dictionary<WeakKey<UISwipeGestureRecognizer>,Array<(gestureRecognizer: UISwipeGestureRecognizer) -> ()>>()
    static var tapListeners = Dictionary<WeakKey<UITapGestureRecognizer>,Array<(gestureRecognizer: UITapGestureRecognizer) -> ()>>()
    
    static func addGesture(gesture: UIGestureRecognizer, listener: (gestureRecognizer: UIGestureRecognizer) -> ()) {
        WeakCollections.clean(&gestureListeners)
        let gestureKey = WeakCollections.weakKeyOrNew(gesture, dict: gestureListeners)
        var listeners = gestureListeners[gestureKey]
        if listeners == nil {
            listeners = Array<(gestureRecognizer: UIGestureRecognizer) -> ()>()
            gestureListeners[gestureKey] = listeners
        }
        listeners!.append(listener)
        gestureListeners[gestureKey] = listeners
    }
    
    static func addGesture(gesture: UIPanGestureRecognizer, listener: (gestureRecognizer: UIPanGestureRecognizer) -> ()) {
        WeakCollections.clean(&panListeners)
        let gestureKey = WeakCollections.weakKeyOrNew(gesture, dict: panListeners)
        var listeners = panListeners[gestureKey]
        if listeners == nil {
            listeners = Array<(gestureRecognizer: UIPanGestureRecognizer) -> ()>()
            panListeners[gestureKey] = listeners
        }
        listeners!.append(listener)
        panListeners[gestureKey] = listeners
    }
    
    static func addGesture(gesture: UISwipeGestureRecognizer, listener: (gestureRecognizer: UISwipeGestureRecognizer) -> ()) {
        var gestureListeners = swipeListeners
        WeakCollections.clean(&gestureListeners)
        let gestureKey = WeakCollections.weakKeyOrNew(gesture, dict: gestureListeners)
        var listeners = gestureListeners[gestureKey]
        if listeners == nil {
            listeners = Array<(gestureRecognizer: UISwipeGestureRecognizer) -> ()>()
            gestureListeners[gestureKey] = listeners
        }
        listeners!.append(listener)
        gestureListeners[gestureKey] = listeners
        self.swipeListeners = gestureListeners
    }
    
    static func addGesture(gesture: UITapGestureRecognizer, listener: (gestureRecognizer: UITapGestureRecognizer) -> ()) {
        var gestureListeners = tapListeners
        println("add tap gesture")
        WeakCollections.clean(&gestureListeners)
        let gestureKey = WeakCollections.weakKeyOrNew(gesture, dict: gestureListeners)
        var listeners = gestureListeners[gestureKey]
        if listeners == nil {
            listeners = Array<(gestureRecognizer: UITapGestureRecognizer) -> ()>()
            gestureListeners[gestureKey] = listeners
        }
        listeners!.append(listener)
        gestureListeners[gestureKey] = listeners
        self.tapListeners = gestureListeners
    }
    
    static func addGesture(gesture: UIPinchGestureRecognizer, listener: (gestureRecognizer: UIPinchGestureRecognizer) -> ()) {
        var gestureListeners = pinchListeners
        WeakCollections.clean(&gestureListeners)
        let gestureKey = WeakCollections.weakKeyOrNew(gesture, dict: gestureListeners)
        var listeners = gestureListeners[gestureKey]
        if listeners == nil {
            listeners = Array<(gestureRecognizer: UIPinchGestureRecognizer) -> ()>()
            gestureListeners[gestureKey] = listeners
        }
        listeners!.append(listener)
        gestureListeners[gestureKey] = listeners
        self.pinchListeners = gestureListeners
    }
    
    static func addGesture(gesture: UILongPressGestureRecognizer, listener: (gestureRecognizer: UILongPressGestureRecognizer) -> ()) {
        var gestureListeners = longPressListeners
        WeakCollections.clean(&gestureListeners)
        let gestureKey = WeakCollections.weakKeyOrNew(gesture, dict: gestureListeners)
        var listeners = gestureListeners[gestureKey]
        if listeners == nil {
            listeners = Array<(gestureRecognizer: UILongPressGestureRecognizer) -> ()>()
            gestureListeners[gestureKey] = listeners
        }
        listeners!.append(listener)
        gestureListeners[gestureKey] = listeners
        self.longPressListeners = gestureListeners
    }
    
    static func addGesture(gesture: UIRotationGestureRecognizer, listener: (gestureRecognizer: UIRotationGestureRecognizer) -> ()) {
        var gestureListeners = rotationListeners
        WeakCollections.clean(&gestureListeners)
        let gestureKey = WeakCollections.weakKeyOrNew(gesture, dict: gestureListeners)
        var listeners = gestureListeners[gestureKey]
        if listeners == nil {
            listeners = Array<(gestureRecognizer: UIRotationGestureRecognizer) -> ()>()
            gestureListeners[gestureKey] = listeners
        }
        listeners!.append(listener)
        gestureListeners[gestureKey] = listeners
        self.rotationListeners = gestureListeners
    }
    
    static func removeGesture(gesture: UIGestureRecognizer, listener:(gestureRecognizer: UIGestureRecognizer) -> () ) {
        WeakCollections.clean(&gestureListeners)
        if let gestureKey = WeakCollections.weakKey(gesture, dictionary: gestureListeners) {
            var lists = gestureListeners[gestureKey]!
            var indexForRemove = -1
            for (index, list) in enumerate(lists) {
                if list === listener {
                    indexForRemove = index
                }
            }
            if indexForRemove > -1 {
                let f = lists.removeAtIndex(indexForRemove)
                gestureListeners[gestureKey] = lists
            }
        }
    }
    
    static func removeGesture(gesture: UITapGestureRecognizer, listener:(gestureRecognizer: UITapGestureRecognizer) -> () ) {
        var gestureListeners = tapListeners
        WeakCollections.clean(&gestureListeners)
        if let gestureKey = WeakCollections.weakKey(gesture, dictionary: gestureListeners) {
            var lists = gestureListeners[gestureKey]!
            var indexForRemove = -1
            for (index, list) in enumerate(lists) {
                if list === listener {
                    indexForRemove = index
                }
            }
            if indexForRemove > -1 {
                let f = lists.removeAtIndex(indexForRemove)
                gestureListeners[gestureKey] = lists
            }
        }
        self.tapListeners = gestureListeners
    }
    
    static func removeGesture(gesture: UIPanGestureRecognizer, listener:(gestureRecognizer: UIPanGestureRecognizer) -> () ) {
        var gestureListeners = panListeners
        WeakCollections.clean(&gestureListeners)
        if let gestureKey = WeakCollections.weakKey(gesture, dictionary: gestureListeners) {
            var lists = gestureListeners[gestureKey]!
            var indexForRemove = -1
            for (index, list) in enumerate(lists) {
                if list === listener {
                    indexForRemove = index
                }
            }
            if indexForRemove > -1 {
                let f = lists.removeAtIndex(indexForRemove)
                gestureListeners[gestureKey] = lists
            }
        }
        self.panListeners = gestureListeners
    }
    
    static func removeGesture(gesture: UISwipeGestureRecognizer, listener:(gestureRecognizer: UISwipeGestureRecognizer) -> () ) {
        var gestureListeners = swipeListeners
        WeakCollections.clean(&gestureListeners)
        if let gestureKey = WeakCollections.weakKey(gesture, dictionary: gestureListeners) {
            var lists = gestureListeners[gestureKey]!
            var indexForRemove = -1
            for (index, list) in enumerate(lists) {
                if list === listener {
                    indexForRemove = index
                }
            }
            if indexForRemove > -1 {
                let f = lists.removeAtIndex(indexForRemove)
                gestureListeners[gestureKey] = lists
            }
        }
        self.swipeListeners = gestureListeners
    }
    
    static func removeGesture(gesture: UIPinchGestureRecognizer, listener:(gestureRecognizer: UIPinchGestureRecognizer) -> () ) {
        var gestureListeners = pinchListeners
        WeakCollections.clean(&gestureListeners)
        if let gestureKey = WeakCollections.weakKey(gesture, dictionary: gestureListeners) {
            var lists = gestureListeners[gestureKey]!
            var indexForRemove = -1
            for (index, list) in enumerate(lists) {
                if list === listener {
                    indexForRemove = index
                }
            }
            if indexForRemove > -1 {
                let f = lists.removeAtIndex(indexForRemove)
                gestureListeners[gestureKey] = lists
            }
        }
        self.pinchListeners = gestureListeners
    }
    
    static func removeGesture(gesture: UIRotationGestureRecognizer, listener:(gestureRecognizer: UIRotationGestureRecognizer) -> () ) {
        var gestureListeners = rotationListeners
        WeakCollections.clean(&gestureListeners)
        if let gestureKey = WeakCollections.weakKey(gesture, dictionary: gestureListeners) {
            var lists = gestureListeners[gestureKey]!
            var indexForRemove = -1
            for (index, list) in enumerate(lists) {
                if list === listener {
                    indexForRemove = index
                }
            }
            if indexForRemove > -1 {
                let f = lists.removeAtIndex(indexForRemove)
                gestureListeners[gestureKey] = lists
            }
        }
        self.rotationListeners = gestureListeners
    }
    
    static func removeGesture(gesture: UILongPressGestureRecognizer, listener:(gestureRecognizer: UILongPressGestureRecognizer) -> () ) {
        var gestureListeners = longPressListeners
        WeakCollections.clean(&gestureListeners)
        if let gestureKey = WeakCollections.weakKey(gesture, dictionary: gestureListeners) {
            var lists = gestureListeners[gestureKey]!
            var indexForRemove = -1
            for (index, list) in enumerate(lists) {
                if list === listener {
                    indexForRemove = index
                }
            }
            if indexForRemove > -1 {
                let f = lists.removeAtIndex(indexForRemove)
                gestureListeners[gestureKey] = lists
            }
        }
        self.longPressListeners = gestureListeners
    }
    
    public static dynamic func handleGesture(gesture: UIGestureRecognizer) {
        println("handle gesture")
        if gesture is UITapGestureRecognizer {
            println("have tap gesture")
            println(tapListeners.count)
            let gest = gesture as! UITapGestureRecognizer
            if let lists = WeakCollections.valueForWeakKey(gest, dict: tapListeners) {
                for f in lists {
                    f(gestureRecognizer: gest)
                }
            }
        } else if gesture is UIPinchGestureRecognizer {
            let gest = gesture as! UIPinchGestureRecognizer
            if let lists = WeakCollections.valueForWeakKey(gest, dict: pinchListeners) {
                for f in lists {
                    f(gestureRecognizer: gest)
                }
            }
        } else if gesture is UILongPressGestureRecognizer {
            let gest = gesture as! UILongPressGestureRecognizer
            if let lists = WeakCollections.valueForWeakKey(gest, dict: longPressListeners) {
                for f in lists {
                    f(gestureRecognizer: gest)
                }
            }
        } else if gesture is UIPanGestureRecognizer {
            let gest = gesture as! UIPanGestureRecognizer
            if let lists = WeakCollections.valueForWeakKey(gest, dict: panListeners) {
                for f in lists {
                    f(gestureRecognizer: gest)
                }
            }
        } else if gesture is UIRotationGestureRecognizer {
            let gest = gesture as! UIRotationGestureRecognizer
            if let lists = WeakCollections.valueForWeakKey(gest, dict: rotationListeners) {
                for f in lists {
                    f(gestureRecognizer: gest)
                }
            }
        } else if gesture is UISwipeGestureRecognizer {
            let gest = gesture as! UISwipeGestureRecognizer
            if let lists = WeakCollections.valueForWeakKey(gest, dict: swipeListeners) {
                for f in lists {
                    f(gestureRecognizer: gest)
                }
            }
        } else if let lists = WeakCollections.valueForWeakKey(gesture, dict: gestureListeners) {
            for f in lists {
                f(gestureRecognizer: gesture)
            }
        }
    }
    
    public static dynamic func touchCancel(sender: AnyObject) {
        self.handleEvent(.TouchCancel, sender: sender as! UIView)
    }
    
    public static dynamic func touchDown(sender: AnyObject) {
        self.handleEvent(.TouchDown, sender: sender as! UIView)
    }
    
    public static dynamic func touchDownRepeat(sender: AnyObject) {
        self.handleEvent(.TouchDownRepeat, sender: sender as! UIView)
    }
    
    public static dynamic func touchDragEnter(sender: AnyObject) {
        self.handleEvent(.TouchDragEnter, sender: sender as! UIView)
    }
    
    public static dynamic func touchDragExit(sender: AnyObject) {
        self.handleEvent(.TouchDragExit, sender: sender as! UIView)
    }
    
    public static dynamic func touchUpInside(sender: AnyObject) {
        self.handleEvent(.TouchUpInside, sender: sender as! UIView)
    }
    
    public static dynamic func touchUpOutside(sender: AnyObject) {
        self.handleEvent(.TouchUpOutside, sender: sender as! UIView)
    }
    
    public static dynamic func valueChanged(sender: AnyObject) {
        self.handleEvent(.ValueChanged, sender: sender as! UIView)
    }
    
    public static dynamic func editingChanged(sender: AnyObject) {
        self.handleEvent(.EditingChanged, sender: sender as! UIView)
    }
    
    public static dynamic func editingDidBegin(sender: AnyObject) {
        self.handleEvent(.EditingDidBegin, sender: sender as! UIView)
    }
    
    public static dynamic func editingDidEnd(sender: AnyObject) {
        self.handleEvent(.EditingDidEnd, sender: sender as! UIView)
    }
    
    public static dynamic func editingDidEndOnExit(sender: AnyObject) {
        self.handleEvent(.EditingDidEndOnExit, sender: sender as! UIView)
    }
    
    public static dynamic func systemReserved(sender: AnyObject) {
        self.handleEvent(.SystemReserved, sender: sender as! UIView)
    }
    
    public static dynamic func applicationReserved(sender: AnyObject) {
        self.handleEvent(.ApplicationReserved, sender: sender as! UIView)
    }
    
    public static dynamic func allEvents(sender: AnyObject) {
        self.handleEvent(.AllEvents, sender: sender as! UIView)
    }
    
    public static dynamic func allTouchEvents(sender: AnyObject) {
        self.handleEvent(.AllTouchEvents, sender: sender as! UIView)
    }
    
    public static dynamic func allEditingEvents(sender: AnyObject) {
        self.handleEvent(.AllEditingEvents, sender: sender as! UIView)
    }
    
    static func selector(event: AUIControlEvent) -> Selector {
        switch event {
        case .TouchCancel:
            return "touchCancel:"
        case .TouchDown:
            return "touchDown:"
        case .TouchDownRepeat:
            return "touchDownRepeat:"
        case .TouchDragEnter:
            return "touchDragEnter:"
        case .TouchDragExit:
            return "touchDragExit:"
        case .TouchDragInside:
            return "touchDragInside:"
        case .TouchDragOutside:
            return "touchDragOutside:"
        case .TouchUpInside:
            return "touchUpInside:"
        case .TouchUpOutside:
            return "touchUpOutside:"
        case .ValueChanged:
            return "valueChanged:"
        case .EditingChanged:
            return "editingChanged:"
        case .EditingDidBegin:
            return "editingDidBegin:"
        case .EditingDidEnd:
            return "editingDidEnd:"
        case .EditingDidEndOnExit:
            return "editingDidEndOnExit:"
        case .SystemReserved:
            return "systemReserved:"
        case .ApplicationReserved:
            return "applicationReserved:"
        case .AllEvents:
            return "allEvents:"
        case .AllTouchEvents:
            return "allTouchEvents:"
        case .AllEditingEvents:
            return "allEditingEvents:"
        }
    }
}

public extension UIControl {
    public func on(event: UIControlEvents, listener: (sender: AnyObject) -> ()) {
        self.addListener(event, listener: listener)
    }
    public func onTouchUpInside(listener: (sender: AnyObject) -> ()) {
        self.on(.TouchUpInside, listener: listener)
    }
    public func onTouchUpOutside(listener: (sender: AnyObject) -> ()) {
        self.on(.TouchUpOutside, listener: listener)
    }
    public func onValueChanged(listener: (sender: AnyObject) -> ()) {
        self.on(.ValueChanged, listener: listener)
    }
    public func onTouchCancel(listener: (sender: AnyObject) -> ()) {
        self.on(.TouchCancel, listener: listener)
    }
    public func onTouchDown(listener: (sender: AnyObject) -> ()) {
        self.on(.TouchDown, listener: listener)
    }
    public func onTouchDownRepeat(listener: (sender: AnyObject) -> ()) {
        self.on(.TouchDownRepeat, listener: listener)
    }
    public func onTouchDragEnter(listener: (sender: AnyObject) -> ()) {
        self.on(.TouchDragEnter, listener: listener)
    }
    public func onTouchDragOutside(listener: (sender: AnyObject) -> ()) {
        self.on(.TouchDragOutside, listener:listener)
    }
    public func onTouchDragInside(listener: (sender: AnyObject) -> ()) {
        self.on(.TouchDragInside, listener: listener)
    }
    public func onTouchDragExit(listener: (sender: AnyObject) -> ()) {
        self.on(.TouchDragExit, listener: listener)
    }
    public func onEditingChanged(listener: (sender: AnyObject) -> ()) {
        self.on(.EditingChanged, listener: listener)
    }
    public func onEditingDidBegin(listener: (sender: AnyObject) -> ()) {
        self.on(.EditingDidBegin, listener: listener)
    }
    public func onEditingDidEnd(listener: (sender: AnyObject) -> ()) {
        self.on(.EditingDidEnd, listener: listener)
    }
    public func onEditingDidEndOnExit(listener: (sender: AnyObject) -> ()) {
        self.on(.EditingDidEndOnExit, listener: listener)
    }
    public func onAllEvents(listener: (sender: AnyObject) -> ()) {
        self.on(.AllEvents, listener: listener)
    }
    public func onAllTouchEvents(listener: (sender: AnyObject) -> ()) {
        self.on(.AllTouchEvents, listener: listener)
    }
    public func onAllEditingEvents(listener: (sender: AnyObject) -> ()) {
        self.on(.AllEditingEvents, listener: listener)
    }
    public func addListener(event: UIControlEvents, listener: (sender: AnyObject) -> ()) {
        ArkUI.addTargetIfNeeded(self, event: event)
        ArkUI.addListener(self, events: AUIControlEvent.auiEventsFromUI(event), listener: listener)
    }
    public func removeListener(event: UIControlEvents, listener: (sender: AnyObject) -> ()) {
        ArkUI.removeListener(self, events: AUIControlEvent.auiEventsFromUI(event), listener: listener)
    }
}

public extension UIGestureRecognizer {
    public convenience init(_ listener:(gestureRecognizer: UIGestureRecognizer) -> () ) {
        self.init(target: ArkUI.self, action: "handleGesture:")
        ArkUI.addGesture(self, listener: listener)
    }
    public func onGesture(listener:(gestureRecognizer: UIGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public func addListener(listener:(gestureRecognizer: UIGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public func removeListener(listener:(gestureRecognizer: UIGestureRecognizer) -> () ) {
        ArkUI.removeGesture(self, listener: listener)
    }
}

public extension UITapGestureRecognizer {
    public convenience init(_ listener:(gestureRecognizer: UITapGestureRecognizer) -> () ) {
        self.init(target: ArkUI.self, action: "handleGesture:")
        ArkUI.addGesture(self, listener: listener)
    }
    public override func onGesture(listener:(gestureRecognizer: UITapGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public override func addListener(listener:(gestureRecognizer: UITapGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public override func removeListener(listener:(gestureRecognizer: UITapGestureRecognizer) -> () ) {
        ArkUI.removeGesture(self, listener: listener)
    }

}

public extension UILongPressGestureRecognizer {
    public convenience init(_ listener:(gestureRecognizer: UILongPressGestureRecognizer) -> () ) {
        self.init(target: ArkUI.self, action: "handleGesture:")
        ArkUI.addGesture(self, listener: listener)
    }
    public override func onGesture(listener:(gestureRecognizer: UILongPressGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public override func addListener(listener:(gestureRecognizer: UILongPressGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public override func removeListener(listener:(gestureRecognizer: UILongPressGestureRecognizer) -> () ) {
        ArkUI.removeGesture(self, listener: listener)
    }
}

public extension UIPanGestureRecognizer {
    public convenience init(_ listener:(gestureRecognizer: UIPanGestureRecognizer) -> () ) {
        self.init(target: ArkUI.self, action: "handleGesture:")
        ArkUI.addGesture(self, listener: listener)
    }
    public override func onGesture(listener:(gestureRecognizer: UIPanGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public override func addListener(listener:(gestureRecognizer: UIPanGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public override func removeListener(listener:(gestureRecognizer: UIPanGestureRecognizer) -> () ) {
        ArkUI.removeGesture(self, listener: listener)
    }
}

public extension UIPinchGestureRecognizer {
    public convenience init(_ listener:(gestureRecognizer: UIPinchGestureRecognizer) -> () ) {
        self.init(target: ArkUI.self, action: "handleGesture:")
        ArkUI.addGesture(self, listener: listener)
    }
    public override func onGesture(listener:(gestureRecognizer: UIPinchGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public override func addListener(listener:(gestureRecognizer: UIPinchGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public override func removeListener(listener:(gestureRecognizer: UIPinchGestureRecognizer) -> () ) {
        ArkUI.removeGesture(self, listener: listener)
    }
}

public extension UIRotationGestureRecognizer {
    public convenience init(_ listener:(gestureRecognizer: UIRotationGestureRecognizer) -> () ) {
        self.init(target: ArkUI.self, action: "handleGesture:")
        ArkUI.addGesture(self, listener: listener)
    }
    public override func onGesture(listener:(gestureRecognizer: UIRotationGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public override func addListener(listener:(gestureRecognizer: UIRotationGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public override func removeListener(listener:(gestureRecognizer: UIRotationGestureRecognizer) -> () ) {
        ArkUI.removeGesture(self, listener: listener)
    }
}

public extension UISwipeGestureRecognizer {
    public convenience init(_ listener:(gestureRecognizer: UISwipeGestureRecognizer) -> () ) {
        self.init(target: ArkUI.self, action: "handleGesture:")
        ArkUI.addGesture(self, listener: listener)
    }
    public override func onGesture(listener:(gestureRecognizer: UISwipeGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public override func addListener(listener:(gestureRecognizer: UISwipeGestureRecognizer) -> () ) {
        ArkUI.addGesture(self, listener: listener)
    }
    public override func removeListener(listener:(gestureRecognizer: UISwipeGestureRecognizer) -> () ) {
        ArkUI.removeGesture(self, listener: listener)
    }
}

func peekFunc<A,R>(f:A->R)->(fp:Int, ctx:Int) {
    typealias IntInt = (Int, Int)
    let (hi, lo) = unsafeBitCast(f, IntInt.self)
    let offset = sizeof(Int) == 8 ? 16 : 12
    let ptr  = UnsafePointer<Int>(bitPattern: lo+offset)
    return (ptr.memory, ptr.successor().memory)
}

func === <A,R>(lhs:A->R,rhs:A->R)->Bool {
    let (tl, tr) = (peekFunc(lhs), peekFunc(rhs))
    return tl.0 == tr.0 && tl.1 == tr.1
}

class Weak<T:AnyObject where T: Equatable> {
    weak var value: T?
    init(value: T) {
        self.value = value
    }
}

class WeakKey<T: AnyObject where T: Hashable>: Weak<T>, Hashable {
    override init(value: T) {
        _hashValue = value.hashValue
        super.init(value: value)
    }
    var hashValue: Int {
        return _hashValue
    }
    let _hashValue: Int
}

func === <T>(lhs: Weak<T>, rhs: Weak<T>) -> Bool {
    if let lhsv = lhs.value {
        if let rhsv = rhs.value {
            return lhsv === rhsv
        }
    }
    return false
}

func === <T>(lhs: WeakKey<T>, rhs: WeakKey<T>) -> Bool {
    if let lhsv = lhs.value {
        if let rhsv = rhs.value {
            return lhsv === rhsv
        }
    }
    return false
}

func == <T where T: Equatable>(lhs: Weak<T>, rhs: Weak<T>) -> Bool {
    if let lhsv = lhs.value {
        if let rhsv = rhs.value {
            return lhsv == rhsv
        }
    }
    return false
}

func == <T where T: Equatable>(lhs: WeakKey<T>, rhs: WeakKey<T>) -> Bool {
    if let lhsv = lhs.value {
        if let rhsv = rhs.value {
            return lhsv == rhsv
        }
    }
    return false
}

class WeakCollections {
    static func valueForWeakKey <T, U>(key: T,dict: [WeakKey<T>:U]) -> U? {
        let keys = dict.keys
        for k in keys {
            if k.hashValue == key.hashValue {
                return dict[k]
            }
        }
        return nil
    }
    
    static func weakKeyOrNew <T:AnyObject,U where T:Hashable>(key: T, dict: Dictionary<WeakKey<T>,U>) -> WeakKey<T> {
        return self.weakKey(key, dictionary: dict) ?? WeakKey<T>(value: key)
    }
    
    static func weakKey <T, U>(key: T, dictionary: Dictionary<WeakKey<T>, U>) -> WeakKey<T>? {
        let keys = dictionary.keys
        for k in keys {
            if k.hashValue == key.hashValue {
                return k
            }
        }
        return nil
    }
    
    static func clean <T, U>(inout dictionary: Dictionary<WeakKey<T>,U>) {
        var needClean = [WeakKey<T>]()
        for k in dictionary.keys {
            if k.value == nil {
                needClean.append(k)
            }
        }
        for k in needClean {
            dictionary.removeValueForKey(k)
        }
    }
}
