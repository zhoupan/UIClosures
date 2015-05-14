//
//  ViewController.swift
//  UIClosuresExample
//
//  Created by Zaid on 5/14/15.
//  Copyright (c) 2015 ark. All rights reserved.
//

import UIKit
import UIClosures

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        button.center = self.view.center
        button.setTitle("Try Me", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.view.addSubview(button)
        button.addListener(UIControlEvents.TouchUpInside, listener: { (sender) -> Void in
            button.setTitle("Tested!", forState: UIControlState.Normal)
        })
        button.addListener(UIControlEvents.TouchUpInside, listener: {[weak btn = button] (sender) -> Void in
            button.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

