//
//  ViewController.swift
//  FMCalendar
//
//  Created by 郑桂华 on 2020/7/2.
//  Copyright © 2020 ZhouFaMing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let calendar = FMCalendarView(dateRange: -1...6, width: UIScreen.main.bounds.width, itemHeight: 59)
        calendar.frame = CGRect(x: 0, y: 200, width: UIScreen.main.bounds.width, height: 400)
        self.view.addSubview(calendar)
    }


}

