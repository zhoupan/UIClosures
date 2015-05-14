//
//  ArkUI.swift
//  
//
//  Created by Zaid on 5/13/15.
//
//

import Foundation

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
    static var listeners = Dictionary<WeakKey<UIView>,[AUIControlEvent:Array<(sender: AnyObject) -> Void>]>()
    static func addListener(view: UIView, events: [AUIControlEvent], listener: (sender: AnyObject) -> Void) {
        WeakCollections.clean(&listeners)
        let viewKey = WeakCollections.weakKeyOrNew(view, dict:listeners)
        var viewListeners = listeners[viewKey]
        if viewListeners == nil {
            viewListeners = [AUIControlEvent:Array<(sender: AnyObject) -> Void>]()
            listeners[viewKey] = viewListeners!
        }
        var lists = viewListeners!
        for event in events {
            var evlist = lists[event]
            if evlist == nil {
                evlist = Array<(sender:AnyObject) -> Void>()
                lists[event] = evlist!
            }
            evlist!.append(listener)
            lists[event] = evlist!
        }
        listeners[viewKey] = lists
    }
    static func removeListener(view: UIView, events: [AUIControlEvent], listener: (sender: AnyObject) -> Void) {
        WeakCollections.clean(&listeners)
        if let viewKey = WeakCollections.weakKey(view, dictionary: listeners) {
            var viewListeners = listeners[viewKey]!
            for event in events {
                if var evlisteners = viewListeners[event] {
                    var indexForRemove = -1
                    for (index, list) in enumerate(evlisteners) {
                        let listfix = list as (sender: AnyObject) -> Void
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
    public func addListener(event: UIControlEvents, listener: (sender: AnyObject) -> Void) {
        ArkUI.addTargetIfNeeded(self, event: event)
        ArkUI.addListener(self, events: AUIControlEvent.auiEventsFromUI(event), listener: listener)
    }
    public func removeListener(event: UIControlEvents, listener: (sender: AnyObject) -> Void) {
        ArkUI.removeListener(self, events: AUIControlEvent.auiEventsFromUI(event), listener: listener)
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
