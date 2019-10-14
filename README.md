# AMNowClockView

![Pod Platform](https://img.shields.io/cocoapods/p/AMNowClockView.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/AMNowClockView.svg?style=flat)
[![Pod Version](https://img.shields.io/cocoapods/v/AMNowClockView.svg?style=flat)](http://cocoapods.org/pods/AMNowClockView)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

`AMNowClockView` is a view can display current time.

## Demo

![now_clock](https://user-images.githubusercontent.com/34936885/66577283-0e6a5100-ebb4-11e9-8fce-7fb8564fb7ba.gif)

## Usage

```swift
let clockView = AMNowClockView(frame: view.bounds)

// customize here

view.addSubview(clockView)
```

### Customization
`AMNowClockView` can be customized via the following properties.

```swift
@IBInspectable public var clockBorderLineWidth: CGFloat = 5.0
@IBInspectable public var smallClockIndexWidth: CGFloat = 1.0
@IBInspectable public var clockIndexWidth: CGFloat = 2.0
@IBInspectable public var hourHandWidth: CGFloat = 3.5
@IBInspectable public var minuteHandWidth: CGFloat = 3.0
@IBInspectable public var secondHandWidth: CGFloat = 1.5
@IBInspectable public var clockBorderLineColor: UIColor = .black
@IBInspectable public var hourHandColor: UIColor = .black
@IBInspectable public var minuteHandColor: UIColor = .black
@IBInspectable public var secondHandColor: UIColor = .black
@IBInspectable public var selectedTimeLabelTextColor: UIColor = .black
@IBInspectable public var timeLabelTextColor: UIColor = .black
@IBInspectable public var smallClockIndexColor: UIColor = .black
@IBInspectable public var clockIndexColor: UIColor = .black
@IBInspectable public var clockColor: UIColor = .clear
@IBInspectable public var clockImage: UIImage?
@IBInspectable public var minuteHandImage: UIImage?
@IBInspectable public var hourHandImage: UIImage?
@IBInspectable public var secondHandImage: UIImage?
@IBInspectable public var isShowSelectedTime: Bool = false
public var clockType: AMNCClockType = .arabic
/// Time zone
///
/// default is TimeZone.current
public var timeZone: TimeZone?
```

Set time zone(from ver.2.1)

```swift
clockView.timeZone = TimeZone(identifier: "GMT")
```

## Installation

### CocoaPods

Add this to your Podfile.

```ogdl
pod 'AMNowClockView'
```

### Carthage

Add this to your Cartfile.

```ogdl
github "adventam10/AMNowClockView"
```

## License

MIT

