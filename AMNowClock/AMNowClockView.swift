//
//  AMNowClockView.swift
//  AMNowClockView, https://github.com/adventam10/AMNowClockView
//
//  Created by am10 on 2017/12/29.
//  Copyright © 2017年 am10. All rights reserved.
//

import UIKit

public enum AMNCClockType {
    case none
    case arabic
   
    var times: [String] {
        switch self {
        case .none:
            return []
        case .arabic:
            return ["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
        }
    }
    
    func time(index: Int) -> String {
        switch self {
        case .none:
            return ""
        case .arabic:
            return times[index]
        }
    }
}

private class AMNowClockModel {
    
    enum AMNCDateFormat: String {
        case hour = "HH"
        case minute = "mm"
        case time = "HH:mm"
    }
    
    let noonAngle = Float(Double.pi/2 + Double.pi)
    var calendar = Calendar(identifier: .gregorian)
    var currentDate = Date()
    var timer: Timer?
    private let dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        return df
    }()
    
    func formattedTime(_ format: AMNCDateFormat) -> String {
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: currentDate)
    }
    
    // MARK:- Calculate
    func calculateAngle(second: Int) -> Float {
        let angle: Float = Float((2*Double.pi)/60) * Float(second)
        return  angle + noonAngle
    }
    
    func calculateAngle(minute: Int) -> Float {
        let angle: Float = Float((2*Double.pi)/60) * Float(minute)
        return  angle + noonAngle
    }
    
    func calculateAngle(hour:Int) -> Float {
        var hourInt = hour
        if hourInt > 12 {
            hourInt -= 12
        }
        
        let angle: Float = Float((2*Double.pi)/12) * Float(hourInt)
        return  angle + noonAngle
    }
    
    func compensationHourAngle() -> Float {
        let components = getComponents(date: currentDate)
        var hourAngle: Float = calculateAngle(hour: components.hour!)
        hourAngle += (Float(components.minute!)/60.0) * Float((2*Double.pi)/12)
        return hourAngle
    }
    
    func compensationMinuteAngle() -> Float {
        let components = getComponents(date: currentDate)
        var minuteAngle: Float = calculateAngle(minute: components.minute!)
        minuteAngle += (Float(components.second!)/60.0) * Float((2*Double.pi)/60)
        return minuteAngle
    }
    
    func adjustFont(rect: CGRect) -> UIFont {
        let length = (rect.width > rect.height) ? rect.height : rect.width
        return .systemFont(ofSize: length * 0.8)
    }
    
    func getComponents(date: Date) -> DateComponents {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                 from: date)
        return components
    }
}

@IBDesignable public class AMNowClockView: UIView {
    
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
    @IBInspectable public var isShowSelectedTime: Bool = false {
        didSet {
            selectedTimeLabel.isHidden = !isShowSelectedTime
        }
    }
    public var clockType: AMNCClockType = .arabic
    /// Time zone
    ///
    /// default is TimeZone.current
    public var timeZone: TimeZone? {
        didSet {
            if let timeZone = timeZone {
                model.calendar.timeZone = timeZone
            } else {
                model.calendar.timeZone = TimeZone.current
            }
        }
    }
    
    override public var bounds: CGRect {
        didSet {
            relodClock()
            drawClock()
        }
    }
    
    private let model = AMNowClockModel()
    private let clockSpace: CGFloat = 10
    private let clockView = UIView()
    private let clockImageView = UIImageView()
    private let minuteHandImageView = UIImageView()
    private let hourHandImageView = UIImageView()
    private let secondHandImageView = UIImageView()
    private let selectedTimeLabel = UILabel()
    
    private var drawLayer: CAShapeLayer?
    private var hourHandLayer: CAShapeLayer?
    private var minuteHandLayer: CAShapeLayer?
    private var secondHandLayer: CAShapeLayer?
    private var radius: CGFloat {
        return clockView.frame.width/2
    }
    private var clockCenter: CGPoint {
        return CGPoint(x: radius, y: radius)
    }
    private var hourHandLength: CGFloat {
        return radius * 0.6
    }
    private var minuteHandLength: CGFloat {
        return radius * 0.8
    }
    private var secondHandLength: CGFloat {
        return radius * 0.8
    }
    
    // MARK:- Initialize
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override public func draw(_ rect: CGRect) {
        relodClock()
        drawClock()
    }
    
    // MARK: - Prepare View
    private func prepareClockView() {
        var length: CGFloat = (frame.width < frame.height) ? frame.width : frame.height
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
        selectedTimeLabel.frame = CGRect(x: clockCenter.x - (radius/2)/2,
                                         y: clockCenter.y - radius/3,
                                         width: radius/2, height: radius/3)
        clockView.addSubview(selectedTimeLabel)
        selectedTimeLabel.font = model.adjustFont(rect: selectedTimeLabel.frame)
        selectedTimeLabel.adjustsFontSizeToFitWidth = true
        selectedTimeLabel.textColor = selectedTimeLabelTextColor
        selectedTimeLabel.textAlignment = .center
        selectedTimeLabel.isHidden = !isShowSelectedTime
    }
    
    private func prepareTimeLabel() {
        var angle = model.noonAngle
        var smallRadius: CGFloat = radius - (radius/10 + clockBorderLineWidth)
        let length: CGFloat = radius/4
        smallRadius -= length/2
        
        // draw line (from center to out)
        for i in 0..<12 {
            let label = makeTimeLabel(length: length)
            label.text = clockType.time(index: i)
            label.font = model.adjustFont(rect: label.frame)
            clockView.addSubview(label)
            let point = CGPoint(x: clockCenter.x + smallRadius * CGFloat(cosf(angle)),
                                y: clockCenter.y + smallRadius * CGFloat(sinf(angle)))
            label.center = point
            angle += Float(Double.pi/6)
        }
    }
    
    private func makeTimeLabel(length: CGFloat) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: length, height: length))
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = timeLabelTextColor
        return label
    }
    
    // MARK: - Make Layer
    private func makeDrawLayer() -> CAShapeLayer {
        let drawLayer = CAShapeLayer()
        drawLayer.frame = clockView.bounds
        drawLayer.cornerRadius = radius
        drawLayer.masksToBounds = true
        
        if clockImage == nil {
            drawLayer.borderWidth = clockBorderLineWidth
            drawLayer.borderColor = clockBorderLineColor.cgColor
            drawLayer.backgroundColor = clockColor.cgColor
        }
        return drawLayer
    }
    
    private func makeSmallClockIndexLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = drawLayer!.bounds
        layer.strokeColor = clockIndexColor.cgColor
        layer.fillColor = UIColor.clear.cgColor;
        
        var angle = model.noonAngle
        let smallRadius: CGFloat = radius - (radius/20 + clockBorderLineWidth)
        
        let path = UIBezierPath()
        // draw line (from center to out)
        for i in 0..<60 {
            if i%5 != 0 {
                let start = CGPoint(x: clockCenter.x + radius * CGFloat(cosf(angle)),
                                    y: clockCenter.y + radius * CGFloat(sinf(angle)))
                path.move(to: start)
                let end = CGPoint(x: clockCenter.x + smallRadius * CGFloat(cosf(angle)),
                                  y: clockCenter.y + smallRadius * CGFloat(sinf(angle)))
                path.addLine(to: end)
            }
            
            angle += Float(Double.pi/30)
        }
        layer.lineWidth = smallClockIndexWidth
        layer.path = path.cgPath
        return layer
    }
    
    private func makeClockIndexLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = drawLayer!.bounds
        layer.strokeColor = clockIndexColor.cgColor
        layer.fillColor = UIColor.clear.cgColor;
        
        var angle = model.noonAngle
        let smallRadius: CGFloat = radius - (radius/10 + clockBorderLineWidth)
        
        let path = UIBezierPath()
        // draw line (from center to out)
        for _ in 0..<12 {
            let start = CGPoint(x: clockCenter.x + radius * CGFloat(cosf(angle)),
                                y: clockCenter.y + radius * CGFloat(sinf(angle)))
            path.move(to: start)
            let end = CGPoint(x: clockCenter.x + smallRadius * CGFloat(cosf(angle)),
                              y: clockCenter.y + smallRadius * CGFloat(sinf(angle)))
            path.addLine(to: end)
            angle += Float(Double.pi/6)
        }
        layer.lineWidth = clockIndexWidth
        layer.path = path.cgPath
        return layer
    }
    
    private func makeHourHandLayer() -> CAShapeLayer {
        let hourHandLayer = CAShapeLayer()
        hourHandLayer.frame = drawLayer!.bounds
        hourHandLayer.strokeColor = hourHandColor.cgColor
        hourHandLayer.fillColor = UIColor.clear.cgColor
        hourHandLayer.lineWidth = hourHandWidth
        hourHandLayer.path = makeHandPath(length: hourHandLength,
                                          angle: model.noonAngle).cgPath
        return hourHandLayer
    }
    
    private func makeMinuteHandLayer() -> CAShapeLayer {
        let minuteHandLayer = CAShapeLayer()
        minuteHandLayer.frame = drawLayer!.bounds
        minuteHandLayer.strokeColor = minuteHandColor.cgColor
        minuteHandLayer.fillColor = UIColor.clear.cgColor
        minuteHandLayer.lineWidth = minuteHandWidth
        minuteHandLayer.path = makeHandPath(length: minuteHandLength,
                                            angle: model.noonAngle).cgPath
        return minuteHandLayer
    }
    
    private func makeSecondHandLayer() -> CAShapeLayer {
        let secondHandLayer = CAShapeLayer()
        secondHandLayer.frame = drawLayer!.bounds
        secondHandLayer.strokeColor = secondHandColor.cgColor
        secondHandLayer.fillColor = UIColor.clear.cgColor
        secondHandLayer.lineWidth = secondHandWidth
        secondHandLayer.path = makeHandPath(length: secondHandLength,
                                            angle: model.noonAngle).cgPath
        return secondHandLayer
    }
    
    private func makeHandPath(length: CGFloat, angle: Float) -> UIBezierPath {
        let path = UIBezierPath()
        let point = CGPoint(x: clockCenter.x + length * CGFloat(cosf(angle)),
                            y: clockCenter.y + length * CGFloat(sinf(angle)))
        path.move(to: clockCenter)
        path.addLine(to: point)
        return path
    }
    
    // MARK:- Draw Hand
    private func drawSecondHandLayer(angle: Float) {
        if secondHandImage != nil {
            let rotation = angle - model.noonAngle
            secondHandImageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
            return
        }
        
        guard let secondHandLayer = secondHandLayer else {
            return
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        secondHandLayer.path = makeHandPath(length: secondHandLength, angle: angle).cgPath
        CATransaction.commit()
    }
    
    private func drawMinuteHandLayer(angle: Float) {
        if minuteHandImage != nil {
            let rotation = angle - model.noonAngle
            minuteHandImageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
            return
        }
        
        guard let minuteHandLayer = minuteHandLayer else {
            return
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        minuteHandLayer.path = makeHandPath(length: minuteHandLength, angle: angle).cgPath
        CATransaction.commit()
    }
    
    private func drawHourHandLayer(angle: Float) {
        if hourHandImage != nil {
            clockImageView.image = clockImage
            minuteHandImageView.image = minuteHandImage
            hourHandImageView.image = hourHandImage
            secondHandImageView.image = secondHandImage
            let rotation = angle - model.noonAngle
            hourHandImageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
            return
        }
        
        guard let hourHandLayer = hourHandLayer else {
            return
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        hourHandLayer.path = makeHandPath(length: hourHandLength, angle: angle).cgPath
        CATransaction.commit()
    }
    
    private func drawClock() {
        model.currentDate = Date()
        let components = model.getComponents(date: model.currentDate)
        drawSecondHandLayer(angle: model.calculateAngle(second: components.second!))
        drawMinuteHandLayer(angle: model.compensationMinuteAngle())
        drawHourHandLayer(angle: model.compensationHourAngle())
        selectedTimeLabel.text = model.formattedTime(.time)
    }
    
    // MARK:- Timer Action
    @objc func timerAction(teimer: Timer) {
        drawClock()
    }
    
    // MARK:- Shwo/Clear
    private func clear() {
        clockView.subviews.forEach { $0.removeFromSuperview() }
        
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
        
        drawLayer = makeDrawLayer()
        clockView.layer.addSublayer(drawLayer!)
        
        if clockImage == nil {
            drawLayer!.addSublayer(makeSmallClockIndexLayer())
            drawLayer!.addSublayer(makeClockIndexLayer())
            prepareTimeLabel()
        }
        
        if hourHandImage == nil {
            hourHandLayer = makeHourHandLayer()
            drawLayer!.addSublayer(hourHandLayer!)
        }
        
        if minuteHandImage == nil {
            minuteHandLayer = makeMinuteHandLayer()
            drawLayer!.addSublayer(minuteHandLayer!)
        }
        
        if secondHandImage == nil {
            secondHandLayer = makeSecondHandLayer()
            drawLayer!.addSublayer(secondHandLayer!)
        }
        
        prepareSelectedTimeLabel()
        
        if model.timer == nil {
            model.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                         target: self,
                                         selector: #selector(self.timerAction(teimer:)),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
}
