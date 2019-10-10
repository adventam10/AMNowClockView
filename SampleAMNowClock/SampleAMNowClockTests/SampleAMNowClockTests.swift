//
//  SampleAMNowClockTests.swift
//  SampleAMNowClockTests
//
//  Created by am10 on 2019/10/10.
//  Copyright © 2019 am10. All rights reserved.
//

import XCTest
@testable import SampleAMNowClock

class SampleAMNowClockTests: XCTestCase {

    private let dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.locale = .init(identifier: "ja_JP")
        df.dateFormat = "yyyyMMddHHmmss"
        return df
    }()
    private let accuracy: Float = 0.00001
    private let anglePerSecond = Float((2 * Double.pi) / 60)
    private let anglePerMinute = Float((2 * Double.pi) / 60)
    private let anglePerHour = Float((2 * Double.pi) / 12)
    private let angle270 = Float(Double.pi/2 + Double.pi)
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCurrentSecondAngle() {
        let model = AMNowClockModel()
        model.currentDate = dateFormatter.date(from: "20191205120000")!
        XCTAssertEqual(cosf(model.currentSecondAngle), 0.0, accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191205120015")!
        XCTAssertEqual(cosf(model.currentSecondAngle), 1.0, accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215120030")!
        XCTAssertEqual(cosf(model.currentSecondAngle), 0.0, accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215120045")!
        XCTAssertEqual(cosf(model.currentSecondAngle), -1.0, accuracy: accuracy)
        
        model.currentDate = dateFormatter.date(from: "20191215120013")!
        XCTAssertEqual(cosf(model.currentSecondAngle), cosf(angle270 + anglePerSecond*13), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215120022")!
        XCTAssertEqual(cosf(model.currentSecondAngle), cosf(angle270 + anglePerSecond*22), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215120036")!
        XCTAssertEqual(cosf(model.currentSecondAngle), cosf(angle270 + anglePerSecond*36), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215120052")!
        XCTAssertEqual(cosf(model.currentSecondAngle), cosf(angle270 + anglePerSecond*52), accuracy: accuracy)
    }
    
    func testCurrentMinuteAngle() {
        let model = AMNowClockModel()
        model.currentDate = dateFormatter.date(from: "20191210120000")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), 0.0, accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191210121500")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), 1.0, accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191210123000")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), 0.0, accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191210124500")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), -1.0, accuracy: accuracy)
        
        model.currentDate = dateFormatter.date(from: "20191215121300")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), cosf(angle270 + anglePerMinute*13), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215122200")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), cosf(angle270 + anglePerMinute*22), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215123600")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), cosf(angle270 + anglePerMinute*36), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215125200")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), cosf(angle270 + anglePerMinute*52), accuracy: accuracy)
        
        model.currentDate = dateFormatter.date(from: "20191210120040")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), cosf(reviseAngle(Float(Double.pi/2 + Double.pi), bySecond: 40)), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191210121540")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), cosf(reviseAngle(0, bySecond: 40)), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191210123040")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), cosf(reviseAngle(Float(Double.pi/2), bySecond: 40)), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191210124540")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), cosf(reviseAngle(Float(Double.pi), bySecond: 40)), accuracy: accuracy)
        
        model.currentDate = dateFormatter.date(from: "20191215121325")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), cosf(reviseAngle(angle270 + anglePerMinute*13, bySecond: 25)), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215122230")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), cosf(reviseAngle(angle270 + anglePerMinute*22, bySecond: 30)), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215123655")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), cosf(reviseAngle(angle270 + anglePerMinute*36, bySecond: 55)), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215125244")!
        XCTAssertEqual(cosf(model.currentMinuteAngle), cosf(reviseAngle(angle270 + anglePerMinute*52, bySecond: 44)), accuracy: accuracy)
    }
    
    func testCurrentHourAngle() {
        let model = AMNowClockModel()
        model.currentDate = dateFormatter.date(from: "20191210120000")!
        XCTAssertEqual(cosf(model.currentHourAngle), 0.0, accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191210030000")!
        XCTAssertEqual(cosf(model.currentHourAngle), 1.0, accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191210060000")!
        XCTAssertEqual(cosf(model.currentHourAngle), 0.0, accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191210090000")!
        XCTAssertEqual(cosf(model.currentHourAngle), -1.0, accuracy: accuracy)
        
        model.currentDate = dateFormatter.date(from: "20191215010000")!
        XCTAssertEqual(cosf(model.currentHourAngle), cosf(angle270 + anglePerHour*1), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215040000")!
        XCTAssertEqual(cosf(model.currentHourAngle), cosf(angle270 + anglePerHour*4), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215070000")!
        XCTAssertEqual(cosf(model.currentHourAngle), cosf(angle270 + anglePerHour*7), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215110000")!
        XCTAssertEqual(cosf(model.currentHourAngle), cosf(angle270 + anglePerHour*11), accuracy: accuracy)
        
        model.currentDate = dateFormatter.date(from: "20191210124040")!
        XCTAssertEqual(cosf(model.currentHourAngle), cosf(reviseAngle(Float(Double.pi/2 + Double.pi), byMinute: 40)), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191210031540")!
        XCTAssertEqual(cosf(model.currentHourAngle), cosf(reviseAngle(0, byMinute: 15)), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191210063040")!
        XCTAssertEqual(cosf(model.currentHourAngle), cosf(reviseAngle(Float(Double.pi/2), byMinute: 30)), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191210094540")!
        XCTAssertEqual(cosf(model.currentHourAngle), cosf(reviseAngle(Float(Double.pi), byMinute: 45)), accuracy: accuracy)
        
        model.currentDate = dateFormatter.date(from: "20191215021325")!
        XCTAssertEqual(cosf(model.currentHourAngle), cosf(reviseAngle(angle270 + anglePerHour*2, byMinute: 13)), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215052230")!
        XCTAssertEqual(cosf(model.currentHourAngle), cosf(reviseAngle(angle270 + anglePerHour*5, byMinute: 22)), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215073655")!
        XCTAssertEqual(cosf(model.currentHourAngle), cosf(reviseAngle(angle270 + anglePerHour*7, byMinute: 36)), accuracy: accuracy)
        model.currentDate = dateFormatter.date(from: "20191215115244")!
        XCTAssertEqual(cosf(model.currentHourAngle), cosf(reviseAngle(angle270 + anglePerHour*11, byMinute: 52)), accuracy: accuracy)
    }
    
    func testFormattedTime() {
        let model = AMNowClockModel()
        model.currentDate = dateFormatter.date(from: "20191210123322")!
        XCTAssertEqual(model.formattedTime, "12:33")
    }
    
    private func reviseAngle(_ angle: Float, bySecond second: Float) -> Float {
        return angle + (second / 60.0) * anglePerMinute
    }
    
    private func reviseAngle(_ angle: Float, byMinute minute: Float) -> Float {
        return angle + (minute / 60.0) * anglePerHour
    }
}
