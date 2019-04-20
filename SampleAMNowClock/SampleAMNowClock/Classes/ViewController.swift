//
//  ViewController.swift
//  SampleAMNowClock
//
//  Created by am10 on 2018/01/07.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cView1: AMNowClockView!
    @IBOutlet weak var cView2: AMNowClockView!
    @IBOutlet weak var cView3: AMNowClockView!
    @IBOutlet weak var cView4: AMNowClockView!
    @IBOutlet weak var cView5: AMNowClockView!
    @IBOutlet weak var cView6: AMNowClockView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cView1.timeZone = TimeZone(identifier: "GMT")
        cView2.timeZone = TimeZone(identifier: "Asia/Tokyo")
        cView3.timeZone = TimeZone(identifier: "Australia/Sydney")
        cView4.timeZone = TimeZone(identifier: "Europe/Moscow")
        cView5.timeZone = TimeZone(identifier: "America/Toronto")
        cView6.timeZone = TimeZone(identifier: "Africa/Cairo")
        TimeZone.knownTimeZoneIdentifiers.forEach{print("\($0)\n")}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

