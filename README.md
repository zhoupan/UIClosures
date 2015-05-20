# UIClosures [![CocoaPod][pd-bdg]][pd] [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT) [![Issues](http://img.shields.io/github/issues/arkverse/UIClosures.svg)]( https://github.com/arkverse/UIClosures/issues)
by [ark](http://www.arkverse.com). tweet [@arkverse](https://twitter.com/arkverse) for any feature requests. Feedback is greatly appreciated!
[pd-bdg]: https://img.shields.io/cocoapods/v/UIClosures.svg
[pd]: http://cocoadocs.org/docsets/UIClosures
## About
A Swift closure library for UIKit that makes events significantly easier and cleaner. Currently supports closures on `UIControl` events and `UIGestureRecognizers` (all subclasses). We will be adding more closure support as we go along. Memory managed and written completely in Swift.

All the `UIControlEvents` are supported, and multiple closures can be added to the same event.

Quick example:

```swift
button.on(.TouchUpInside, (sender: AnyObject) -> () {
	let button = sender as! UIButton
	button.setTitle("Pressed", forControlState:.Normal)
})
```

Be sure to check out our [SwiftRecord](https://github.com/arkverse/SwiftRecord) library too!

Visit [ark](www.arkverse.com) for a more [beginner friendly guide to UIClosures](http://www.arkverse.com/release-uiclosures-closure-ui-events-library/)

If you love UIClosures, tweet it! <a href="https://twitter.com/intent/tweet?text=UIClosures&url=https%3A%2F%2Fgithub.com%2Farkverse%2FUIClosures&hashtags=ios%2Cswift%2Cclosures%2Cuikit&original_referer=http%3A%2F%2Fgithub.com%2F&tw_p=tweetbutton" target="_blank">
  <img src="http://jpillora.com/github-twitter-button/img/tweet.png"
       alt="tweet button" title="UIClosures"></img>
</a>


## Installation

#### via [CocoaPods](http://cocoapods.org)
1. Edit your Podfile to use frameworks and add UIClosures:
		
		platform :ios, '8.0'
		use_frameworks!
	
		pod 'UIClosures', '~> 0.0.2'
2. run `pod install`

#### via Carthage

1. Just add UIClosures to your Cartfile:

	github "arkverse/UIClosures" >= 0.0.1
	
2. and run `carthage update`

#### Manual Installation
Drag and drop either `Classes/UIClosures.swift` or `UIClosures.framework` into your project

## Usage

### UIControls

1. `import UIClosures` into your file (if needed)
2. call `on` on your UIControl or one of the convenience methods like `onTouchUpInside`

	```swift
	// Make sure you set your capture list to break your class-closure strong reference loop
	on(.TouchUpInside, listener: { [unowned self] (sender) -> () in
		self.title = "New ViewController Title!"
		let button = sender as! UIButton
		button.titleLabel?.font = UIFont.systemFont
	})
	// Can add another closure to the same event, convenience method used here
	button.onTouchUpInside() {[weak button = button] (sender) -> () in
		button.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
	})
	```
3. Note that you most likely need your capture list for each closure

### UIGestureRecognizer

Use any of the subclasses you want. You **must** use the closure initializer and not the `target: action:`  initializer:

```swift
let tap = UITapGestureRecognizer() { (gesture: UITapGestureRecognizer) -> () in
	println("got a tap")
}

tap.onGesture() { (gesture: UITapGestureRecognizer) -> () in
	println("got this tap again")
}
```
Will call all of your closures

Again, remember your capture list if referring to any variables

##Roadmap

- add more closures
- testing

## License

UIClosures is available under the MIT license. See the LICENSE file
for more information.

Check out [ark](http://www.arkverse.com) for more about us and check out our other Swift libraries

![ga tracker](https://www.google-analytics.com/collect?v=1&a=257770996&t=pageview&dl=https%3A%2F%2Fgithub.com%2Farkverse%2FUIClosures&ul=en-us&de=UTF-8&cid=978224512.1377738459&tid=UA-63011921-2&z=887657232 "ga tracker")
