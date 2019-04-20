//
//  AMNowClockView.swift
//  AMNowClockView, https://github.com/adventam10/AMNowClockView
//
//  Created by am10 on 2017/12/29.
//  Copyright © 2017年 am10. All rights reserved.
//

import UIKit

public enum AMNCDateFormat:String {
    case hour = "HH"
    case minute = "mm"
    case time = "HH:mm"
}

public enum AMNCClockType {
    case none
    case arabic
    case roman
    func timeLabelTitleList() -> [String] {
        switch self {
        case .none:
            return []
        case .arabic:
            return ["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
        case .roman:
            return []
//            return ["Ⅻ", "Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ", "Ⅷ", "Ⅸ", "Ⅹ", "Ⅺ"]
        }
    }
}

@IBDesignable public class AMNowClockView: UIView {
    
    private let noonAngle:Float = Float(Double.pi/2 + Double.pi)
    
    private let clockSpace:CGFloat = 10
    
    private let clockView = UIView()
    
    private let clockImageView = UIImageView()
    
    private let minuteHandImageView = UIImageView()
    
    private let hourHandImageView = UIImageView()
    
    private let secondHandImageView = UIImageView()
    
    private var drawLayer:CAShapeLayer?
    
    private var hourHandLayer:CAShapeLayer?
    
    private var minuteHandLayer:CAShapeLayer?
    
    private var secondHandLayer:CAShapeLayer?
    
    private let selectedTimeLabel = UILabel()
    
    private let dateFormatter = DateFormatter()
    
    private var calendar = Calendar(identifier: .gregorian)
    
    private var currentDate:Date? = Date()
    
    private var timer:Timer?
    
    override public var bounds: CGRect {
        didSet {
            relodClock()
            drawClock()
        }
    }
    
    public var clockType = AMNCClockType.arabic
    
    @IBInspectable public var clockBorderLineWidth:CGFloat = 5.0
    
    @IBInspectable public var smallClockIndexWidth:CGFloat = 1.0
    
    @IBInspectable public var clockIndexWidth:CGFloat = 2.0
    
    @IBInspectable public var hourHandWidth:CGFloat = 3.5
    
    @IBInspectable public var minuteHandWidth:CGFloat = 3.0
    
    @IBInspectable public var secondHandWidth:CGFloat = 1.5
    
    @IBInspectable public var clockBorderLineColor:UIColor = UIColor.black
    
    @IBInspectable public var hourHandColor:UIColor = UIColor.black
    
    @IBInspectable public var minuteHandColor:UIColor = UIColor.black
    
    @IBInspectable public var secondHandColor:UIColor = UIColor.black
    
    @IBInspectable public var selectedTimeLabelTextColor:UIColor = UIColor.black
    
    @IBInspectable public var timeLabelTextColor:UIColor = UIColor.black
    
    @IBInspectable public var smallClockIndexColor:UIColor = UIColor.black
    
    @IBInspectable public var clockIndexColor:UIColor = UIColor.black
    
    @IBInspectable public var clockColor:UIColor = UIColor.clear
    
    @IBInspectable public var clockImage:UIImage?
    
    @IBInspectable public var minuteHandImage:UIImage?
    
    @IBInspectable public var hourHandImage:UIImage?
    
    @IBInspectable public var secondHandImage:UIImage?
    
    @IBInspectable public var isShowSelectedTime:Bool = false {
        didSet {
            selectedTimeLabel.isHidden = !isShowSelectedTime
        }
    }
    
    public var timeZone:TimeZone? {
        didSet {
            if let timeZone = timeZone {
                calendar.timeZone = timeZone
            } else {
                calendar.timeZone = TimeZone.current
            }
        }
    }
    
    //MARK:Initialize
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        initView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        initView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func initView() {
        dateFormatter.locale = Locale(identifier: "ja_JP")
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target: self,
                                     selector: #selector(self.timerAction(teimer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    override public func draw(_ rect: CGRect) {
        relodClock()
        drawClock()
    }
    
    //MARK: Prepare
    private func prepareClockView() {
        var length:CGFloat = (frame.width < frame.height) ? frame.width : frame.height
        length -= clockSpace*2
        clockView.frame = CGRect(x: frame.width/2 - length/2,
                                 y: frame.height/2 - length/2,
                                 width: length,
                                 height: length)
        addSubview(clockView)
    }
    
    private func prepareClockImageViews() {
        clockImageView.frame = clockView.bounds
        minuteHandImageView.frame = clockView.bounds
        hourHandImageView.frame = clockView.bounds
        secondHandImageView.frame = clockView.bounds
        
        clockImageView.image = clockImage
        minuteHandImageView.image = minuteHandImage
        hourHandImageView.image = hourHandImage
        secondHandImageView.image = secondHandImage
        
        clockView.addSubview(clockImageView)
        clockView.addSubview(hourHandImageView)
        clockView.addSubview(minuteHandImageView)
        clockView.addSubview(secondHandImageView)
    }
    
    private func prepareSelectedTimeLabel() {
        let radius:CGFloat = clockView.frame.width/2
        let centerPoint = CGPoint(x: radius, y: radius)
        selectedTimeLabel.frame = CGRect(x: centerPoint.x - (radius/2)/2,
                                         y: centerPoint.y - radius/3,
                                         width: radius/2,
                                         height: radius/3)
        clockView.addSubview(selectedTimeLabel)
        selectedTimeLabel.font = adjustFont(rect: selectedTimeLabel.frame)
        selectedTimeLabel.adjustsFontSizeToFitWidth = true
        selectedTimeLabel.textColor = selectedTimeLabelTextColor
        selectedTimeLabel.textAlignment = .center
        selectedTimeLabel.isHidden = !isShowSelectedTime
    }
    
    private func prepareDrawLayer() {
        drawLayer = CAShapeLayer()
        guard let drawLayer = drawLayer else {
            return;
        }
        
        drawLayer.frame = clockView.bounds
        clockView.layer.addSublayer(drawLayer)
        drawLayer.cornerRadius = clockView.frame.width/2
        drawLayer.masksToBounds = true
        
        if clockImage == nil {
            drawLayer.borderWidth = clockBorderLineWidth
            drawLayer.borderColor = clockBorderLineColor.cgColor
            drawLayer.backgroundColor = clockColor.cgColor
        }
    }
    
    private func prepareSmallClockIndexLayer() {
        guard let drawLayer = drawLayer else {
            return;
        }
        
        let layer = CAShapeLayer()
        layer.frame = drawLayer.bounds
        drawLayer.addSublayer(layer)
        layer.strokeColor = clockIndexColor.cgColor
        layer.fillColor = UIColor.clear.cgColor;
        
        var angle:Float = noonAngle
        let radius:CGFloat = clockView.frame.width/2
        let centerPoint = CGPoint(x: radius, y: radius)
        let smallRadius:CGFloat = radius - (radius/20 + clockBorderLineWidth)
        
        let path = UIBezierPath()
        // draw line (from center to out)
        for i in 0..<60 {
            if i%5 != 0 {
                let point = CGPoint(x: centerPoint.x + radius * CGFloat(cosf(angle)),
                                    y: centerPoint.y + radius * CGFloat(sinf(angle)))
                path.move(to: point)
                let point2 = CGPoint(x: centerPoint.x + smallRadius * CGFloat(cosf(angle)),
                                     y: centerPoint.y + smallRadius * CGFloat(sinf(angle)))
                path.addLine(to: point2)
            }
            
            angle += Float(Double.pi/30)
        }
        layer.lineWidth = smallClockIndexWidth
        layer.path = path.cgPath
    }
    
    private func prepareClockIndexLayer() {
        guard let drawLayer = drawLayer else {
            return;
        }
        
        let layer = CAShapeLayer()
        layer.frame = drawLayer.bounds
        drawLayer.addSublayer(layer)
        layer.strokeColor = clockIndexColor.cgColor
        layer.fillColor = UIColor.clear.cgColor;
        
        var angle:Float = noonAngle
        let radius:CGFloat = clockView.frame.width/2
        let centerPoint = CGPoint(x: radius, y: radius)
        let smallRadius:CGFloat = radius - (radius/10 + clockBorderLineWidth)
        
        let path = UIBezierPath()
        // draw line (from center to out)
        for _ in 0..<12 {
            let point = CGPoint(x: centerPoint.x + radius * CGFloat(cosf(angle)),
                                y: centerPoint.y + radius * CGFloat(sinf(angle)))
            path.move(to: point)
            let point2 = CGPoint(x: centerPoint.x + smallRadius * CGFloat(cosf(angle)),
                                 y: centerPoint.y + smallRadius * CGFloat(sinf(angle)))
            path.addLine(to: point2)
            angle += Float(Double.pi/6)
        }
        layer.lineWidth = clockIndexWidth
        layer.path = path.cgPath
    }
    
    private func prepareTimeLabel() {
        var angle:Float = noonAngle
        let radius:CGFloat = clockView.frame.width/2
        let centerPoint = CGPoint(x: radius, y: radius)
        var smallRadius:CGFloat = radius - (radius/10 + clockBorderLineWidth)
        let length:CGFloat = radius/4
        smallRadius -= length/2
        
        // draw line (from center to out)
        for i in 0..<12 {
            let label = UILabel(frame: CGRect(x: 0,
                                              y: 0,
                                              width: length,
                                              height: length))
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center;
            label.textColor = timeLabelTextColor
            switch clockType {
            case .none:
                label.text = ""
            case .arabic:
               label.text = clockType.timeLabelTitleList()[i]
            case .roman:
               label.text = ""
            }
            label.font = adjustFont(rect: label.frame)
            clockView.addSubview(label)
            let point = CGPoint(x: centerPoint.x + smallRadius * CGFloat(cosf(angle)),
                                y: centerPoint.y + smallRadius * CGFloat(sinf(angle)))
            label.center = point
            angle += Float(Double.pi/6)
        }
    }
    
    private func prepareHourHandLayer() {
        hourHandLayer = CAShapeLayer()
        guard let hourHandLayer = hourHandLayer,
            let drawLayer = drawLayer else {
            return
        }
        
        hourHandLayer.frame = drawLayer.bounds
        drawLayer.addSublayer(hourHandLayer)
        hourHandLayer.strokeColor = hourHandColor.cgColor
        hourHandLayer.fillColor = UIColor.clear.cgColor
        
        let angle:Float = noonAngle
        
        let radius:CGFloat = clockView.frame.width/2
        let length:CGFloat = radius * 0.6
        let centerPoint = CGPoint(x: radius, y: radius)
        
        let path = UIBezierPath()
        let point = CGPoint(x: centerPoint.x + length * CGFloat(cosf(angle)),
                            y: centerPoint.y + length * CGFloat(sinf(angle)))
        path.move(to: centerPoint)
        path.addLine(to: point)
        
        hourHandLayer.lineWidth = hourHandWidth
        hourHandLayer.path = path.cgPath
    }
    
    private func prepareMinuteHandLayer() {
        minuteHandLayer = CAShapeLayer()
        guard let minuteHandLayer = minuteHandLayer,
            let drawLayer = drawLayer else {
            return
        }
        
        minuteHandLayer.frame = drawLayer.bounds
        drawLayer.addSublayer(minuteHandLayer)
        minuteHandLayer.strokeColor = minuteHandColor.cgColor
        minuteHandLayer.fillColor = UIColor.clear.cgColor
        
        let angle:Float = noonAngle
        
        let radius:CGFloat = clockView.frame.width/2
        let length:CGFloat = radius * 0.8
        let centerPoint = CGPoint(x: radius, y: radius)
        
        let path = UIBezierPath()
        let point = CGPoint(x: centerPoint.x + length * CGFloat(cosf(angle)),
                            y: centerPoint.y + length * CGFloat(sinf(angle)))
        path.move(to: centerPoint)
        path.addLine(to: point)
        
        minuteHandLayer.lineWidth = minuteHandWidth
        minuteHandLayer.path = path.cgPath
    }
    
    private func prepareSecondHandLayer() {
        secondHandLayer = CAShapeLayer()
        guard let secondHandLayer = secondHandLayer,
            let drawLayer = drawLayer else {
            return
        }
        
        secondHandLayer.frame = drawLayer.bounds
        drawLayer.addSublayer(secondHandLayer)
        secondHandLayer.strokeColor = secondHandColor.cgColor
        secondHandLayer.fillColor = UIColor.clear.cgColor
        
        let angle:Float = noonAngle
        
        let radius:CGFloat = clockView.frame.width/2
        let length:CGFloat = radius * 0.8
        let centerPoint = CGPoint(x: radius, y: radius)
        
        let path = UIBezierPath()
        let point = CGPoint(x: centerPoint.x + length * CGFloat(cosf(angle)),
                            y: centerPoint.y + length * CGFloat(sinf(angle)))
        path.move(to: centerPoint)
        path.addLine(to: point)
        
        secondHandLayer.lineWidth = secondHandWidth
        secondHandLayer.path = path.cgPath
    }
    
    //MARK: Calculate
    private func calculateAngle(second: Int) -> Float {
        let angle:Float = Float((2*Double.pi)/60) * Float(second)
        return  angle + noonAngle
    }
    
    private func calculateAngle(minute: Int) -> Float {
        let angle:Float = Float((2*Double.pi)/60) * Float(minute)
        return  angle + noonAngle
    }
    
    private func calculateAngle(hour:Int) -> Float {
        var hourInt = hour
        if hourInt > 12 {
            hourInt -= 12
        }
        
        let angle:Float = Float((2*Double.pi)/12) * Float(hourInt)
        return  angle + noonAngle
    }
    
    private func compensationHourAngle() -> Float {
        let components = getComponents(date:currentDate!)
        var hourAngle:Float = calculateAngle(hour: components.hour!)
        hourAngle += (Float(components.minute!)/60.0) * Float((2*Double.pi)/12)
        return hourAngle
    }
    
    private func compensationMinuteAngle() -> Float {
        let components = getComponents(date:currentDate!)
        var minuteAngle:Float = calculateAngle(minute: components.minute!)
        minuteAngle += (Float(components.second!)/60.0) * Float((2*Double.pi)/60)
        return minuteAngle
    }
    
    private func adjustFont(rect: CGRect) -> UIFont {
        let length:CGFloat = (rect.width > rect.height) ? rect.height : rect.width
        let font = UIFont.systemFont(ofSize: length * 0.8)
        return font
    }
    
    private func getComponents(date: Date) -> DateComponents {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                 from: date)
        return components
    }
    
    //MARK: Draw Hand
    private func drawSecondHandLayer(angle: Float) {
        if secondHandImage != nil {
            let rotation = angle - noonAngle
            secondHandImageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
            return
        }
        
        guard let secondHandLayer = secondHandLayer else {
            return
        }
        
        let radius:CGFloat = clockView.frame.width/2
        let length:CGFloat = radius * 0.8
        let centerPoint = CGPoint(x: radius, y: radius)
        
        let path = UIBezierPath()
        let point = CGPoint(x: centerPoint.x + length * CGFloat(cosf(angle)),
                            y: centerPoint.y + length * CGFloat(sinf(angle)))
        path.move(to: centerPoint)
        path.addLine(to: point)
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        secondHandLayer.path = path.cgPath
        CATransaction.commit()
    }
    
    private func drawMinuteHandLayer(angle: Float) {
        if minuteHandImage != nil {
            let rotation = angle - noonAngle
            minuteHandImageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
            return
        }
        
        guard let minuteHandLayer = minuteHandLayer else {
            return
        }
        
        let radius:CGFloat = clockView.frame.width/2
        let length:CGFloat = radius * 0.8
        let centerPoint = CGPoint(x: radius, y: radius)
        
        let path = UIBezierPath()
        let point = CGPoint(x: centerPoint.x + length * CGFloat(cosf(angle)),
                            y: centerPoint.y + length * CGFloat(sinf(angle)))
        path.move(to: centerPoint)
        path.addLine(to: point)
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        minuteHandLayer.path = path.cgPath
        CATransaction.commit()
    }
    
    private func drawHourHandLayer(angle: Float) {
        if hourHandImage != nil {
            clockImageView.image = clockImage
            minuteHandImageView.image = minuteHandImage
            hourHandImageView.image = hourHandImage
            secondHandImageView.image = secondHandImage
            let rotation = angle - noonAngle
            hourHandImageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
            return
        }
        
        guard let hourHandLayer = hourHandLayer else {
            return
        }
        
        let radius:CGFloat = clockView.frame.width/2
        let length:CGFloat = radius * 0.6
        let centerPoint = CGPoint(x: radius, y: radius)
        
        let path = UIBezierPath()
        let point = CGPoint(x: centerPoint.x + length * CGFloat(cosf(angle)),
                            y: centerPoint.y + length * CGFloat(sinf(angle)))
        path.move(to: centerPoint)
        path.addLine(to: point)
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        hourHandLayer.path = path.cgPath
        CATransaction.commit()
    }
    
    private func drawClock() {
        currentDate = Date()
        guard let currentDate = currentDate else {
            return
        }
        
        let components = getComponents(date: currentDate)
        drawSecondHandLayer(angle:calculateAngle(second: components.second!))
        drawMinuteHandLayer(angle: compensationMinuteAngle())
        drawHourHandLayer(angle: compensationHourAngle())
        
        dateFormatter.dateFormat = AMNCDateFormat.time.rawValue
        selectedTimeLabel.text = dateFormatter.string(from: currentDate)
    }
    
    //MARK:Timer Action
    @objc func timerAction(teimer: Timer) {
        drawClock()
    }
    
    //MARK:Shwo/Clear
    private func clear() {
        clockView.subviews.forEach{$0.removeFromSuperview()}
        
        selectedTimeLabel.removeFromSuperview()
        clockImageView.removeFromSuperview()
        hourHandImageView.removeFromSuperview()
        minuteHandImageView.removeFromSuperview()
        secondHandImageView.removeFromSuperview()
        clockView.removeFromSuperview()
        drawLayer?.removeFromSuperlayer()
        minuteHandImageView.transform = CGAffineTransform.identity
        hourHandImageView.transform = CGAffineTransform.identity
        secondHandImageView.transform = CGAffineTransform.identity
        
        hourHandLayer = nil
        minuteHandLayer = nil
        secondHandLayer = nil
        drawLayer = nil
    }
    
    public func relodClock() {
        clear()
        
        prepareClockView()
        prepareClockImageViews()
        
        prepareDrawLayer()
        
        if clockImage == nil {
            prepareSmallClockIndexLayer()
            prepareClockIndexLayer()
            prepareTimeLabel()
        }
        
        if hourHandImage == nil {
            prepareHourHandLayer()
        }
        
        if minuteHandImage == nil {
            prepareMinuteHandLayer()
        }
        
        if secondHandImage == nil {
            prepareSecondHandLayer()
        }
        
        prepareSelectedTimeLabel()
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.5,
                                         target: self,
                                         selector: #selector(self.timerAction(teimer:)),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
}
