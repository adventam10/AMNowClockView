// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  AMNowClockView, https://github.com/adventam10/AMNowClockView
//
//  Created by am10 on 2019/10/14.
//  Copyright © 2019年 am10. All rights reserved.
//

import PackageDescription

let package = Package(name: "AMNowClockView",
                      platforms: [.iOS(.v9)],
                      products: [.library(name: "AMNowClockView",
                                          targets: ["AMNowClockView"])],
                      targets: [.target(name: "AMNowClockView",
                                        path: "Source")],
                      swiftLanguageVersions: [.v5])
