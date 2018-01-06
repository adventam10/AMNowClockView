//
//  AMNowClockView.swift
//  TestProject
//
//  Created by am10 on 2017/12/29.
//  Copyright © 2017年 am10. All rights reserved.
//

import UIKit

enum AMNCDateFormat:String {
    case hour = "HH"
    case minute = "mm"
    case time = "HH:mm"
}

/// 時刻編集タイプ
enum AMNCClockType {
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

@IBDesignable class AMNowClockView: UIView {
    
    override var bounds: CGRect {
        
        didSet {
            
            relodClock()
            drawClock()
        }
    }
    
    /// 12時の角度
    private let noonAngle:Float = Float(Double.pi/2 + Double.pi)
    
    /// 時計の上下左右の余白
    private let clockSpace:CGFloat = 10
    
    /// 時計のせるView
    private let clockView = UIView()
    
    /// 時計用ImageView
    private let clockImageView = UIImageView()
    
    /// 長針用ImageView
    private let minuteHandImageView = UIImageView()
    
    /// 短針用ImageView
    private let hourHandImageView = UIImageView()
    
    /// 秒針用ImageView
    private let secondHandImageView = UIImageView()
    
    /// 時計描画用レイヤ（ここに色々なレイヤをのせる）
    private var drawLayer:CAShapeLayer?
    
    /// 短針レイヤ
    private var hourHandLayer:CAShapeLayer?
    
    /// 長針レイヤ
    private var minuteHandLayer:CAShapeLayer?
    
    /// 秒針レイヤ
    private var secondHandLayer:CAShapeLayer?
    
    /// 時刻表示用ラベル
    private let selectedTimeLabel = UILabel()
    
    /// 時間取得用フォーマット
    private let dateFormatter = DateFormatter()
    
    /// カレンダー（時刻設定用）
    private let calendar = Calendar(identifier: .gregorian)
    
    private var currentDate:Date? = Date()
    
    private var timer:Timer?
    
    /// 時計の文字盤の表示形式
    var clockType = AMNCClockType.arabic
    
    /// 時計の枠線の幅
    @IBInspectable var clockBorderLineWidth:CGFloat = 5.0
    
    /// 時計の短目盛りの太さ
    @IBInspectable var smallClockIndexWidth:CGFloat = 1.0
    
    /// 時計の長目盛りの太さ
    @IBInspectable var clockIndexWidth:CGFloat = 2.0
    
    /// 短針の太さ
    @IBInspectable var hourHandWidth:CGFloat = 3.5
    
    /// 長針の太さ
    @IBInspectable var minuteHandWidth:CGFloat = 3.0
    
    /// 秒針の太さ
    @IBInspectable var secondHandWidth:CGFloat = 1.5
    
    /// 時計の枠線の色
    @IBInspectable var clockBorderLineColor:UIColor = UIColor.black
    
    /// 短針の色
    @IBInspectable var hourHandColor:UIColor = UIColor.black
    
    /// 長針の色
    @IBInspectable var minuteHandColor:UIColor = UIColor.black
    
    /// 秒針の色
    @IBInspectable var secondHandColor:UIColor = UIColor.black
    
    /// 選択時間の文字色
    @IBInspectable var selectedTimeLabelTextColor:UIColor = UIColor.black
    
    /// 時計の時間の文字色
    @IBInspectable var timeLabelTextColor:UIColor = UIColor.black
    
    /// 時計の短目盛りの色
    @IBInspectable var smallClockIndexColor:UIColor = UIColor.black
    
    /// 時計の長目盛りの色
    @IBInspectable var clockIndexColor:UIColor = UIColor.black
    
    /// 時計の色
    @IBInspectable var clockColor:UIColor = UIColor.clear
    
    /// 時計用Image
    @IBInspectable var clockImage:UIImage?
    
    /// 長針用Image
    @IBInspectable var minuteHandImage:UIImage?
    
    /// 短針用Image
    @IBInspectable var hourHandImage:UIImage?
    
    /// 秒針用Image
    @IBInspectable var secondHandImage:UIImage?
    
    /// 選択時刻表示フラグ
    @IBInspectable var isShowSelectedTime:Bool = false {
        
        didSet {
            
            selectedTimeLabel.isHidden = !isShowSelectedTime
        }
    }
    
    //MARK:Initialize
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder:aDecoder)
        initView()
    }
    
    override init(frame: CGRect) {
        
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
    
    override func draw(_ rect: CGRect) {
        
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
        // 中心から外への線描画
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
        // 中心から外への線描画
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
        
        // 中心から外への線描画
        for i in 0..<12 {
            
            let label = UILabel(frame: CGRect(x: 0,
                                              y: 0,
                                              width: length,
                                              height: length))
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center;
            label.textColor = timeLabelTextColor
            if clockType == .none {
                
                label.text = ""
                
            } else if clockType == .arabic {
                
                label.text = clockType.timeLabelTitleList()[i]
                
            } else if clockType == .roman {
                
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
        guard let hourHandLayer = hourHandLayer else {
            
            return
        }
        
        guard let drawLayer = drawLayer else {
            
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
        guard let minuteHandLayer = minuteHandLayer else {
            
            return
        }
        
        guard let drawLayer = drawLayer else {
            
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
        guard let secondHandLayer = secondHandLayer else {
            
            return
        }
        
        guard let drawLayer = drawLayer else {
            
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
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
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
    
    func relodClock() {
        
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
