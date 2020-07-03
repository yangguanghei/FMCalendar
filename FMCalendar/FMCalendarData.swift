//
//  FMCalendarData.swift
//  YueYouHui
//
//  Created by 周发明 on 2018/9/5.
//

import UIKit

struct FMCalendarMonthItem {
    let year: Int
    let month: Int
    let weeks: [FMCalendarWeekItem]
}

struct FMCalendarWeekItem {
    let year: Int
    let month: Int
    let startDay: Int
    let days: [FMCalendarDayItem]
}

enum FMDayType {
    case today // 当天
    case before // 当天之前
    case later // 当天之后
}

class FMCalendarDayItem: NSObject {
    init(year: Int, month: Int, day: Int, weekDay: Int, dayType: FMDayType, select: Bool, other: [String:Any]) {
        self.year = year
        self.month = month
        self.day = day
        self.weekDay = weekDay
        self.dayType = dayType
        self.select = select
        self.other = other
        super.init()
    }
    let year: Int
    let month: Int
    let day: Int
    let weekDay: Int //1234567 对应 日一二三四五六
    let dayType: FMDayType
    var canSelect: Bool = false
    
    var select: Bool
    var other: [String:Any] = [String:Any]()
    var bottom: String = ""
    
    var row: Int = 0
    var section: Int = 0
}


class FMCalendarData: NSObject {
    
    static let calendar: Calendar = {
        let calendar = Calendar.current
        return calendar
    }()
    
    static let chinaCalendar: Calendar = {
        let calendar = Calendar(identifier: .chinese)
        return calendar
    }()
    
    static let formatter: DateFormatter = DateFormatter()
    
    static let currentDayItem: FMCalendarDayItem = {
        let date = Date()
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return FMCalendarDayItem(year: year, month: month, day: day, weekDay: 0, dayType: .today, select: false, other: [String:Any]())
    }()
    
    class func getData(_ range: CountableClosedRange<Int>) -> [FMCalendarMonthItem]{
        
        let year = currentDayItem.year
        let month = currentDayItem.month
        let day = currentDayItem.day

        var monthes = [FMCalendarMonthItem]()

        for i in range {
            var currentYear = year
            var currentMonth = month + i
            if currentMonth < 1 {
                currentMonth = 12 + currentMonth % 12
                currentYear = year + i / 12 - 1
            }
            if currentMonth > 12 {
                currentMonth = currentMonth % 12
                currentYear = year + i / 12 + 1
            }
            let monthItem = self.getSection(year: currentYear, month: currentMonth, currentDay: i == 0 ? day : 0)
            monthes.append(monthItem)
        }

        return monthes
    }
    
    class func getSection(year: Int, month: Int, currentDay: Int) -> FMCalendarMonthItem {
        let count = getDaysCount(year: year, month: month)
        
        var today: FMDayType = .today
        var sureType = true
        if currentDayItem.year > year {
            today = .before
        } else if currentDayItem.year < year {
            today = .later
        } else {
            if currentDayItem.month > month {
                today = .before
            } else if currentDayItem.month < month {
                today = .later
            } else {
                sureType = false
            }
        }
        
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: "\(year)-\(month)-\(1)")
        var dayWeek = calendar.component(.weekday, from: date!)
        
        var days = [FMCalendarDayItem]()
        var weeks = [FMCalendarWeekItem]()
        var startWeekDay = dayWeek
        for i in 1...count {
            if dayWeek > 7 {
                dayWeek = 1
                weeks.append(FMCalendarWeekItem(year: year, month: month, startDay: startWeekDay, days: days))
                days = [FMCalendarDayItem]()
                startWeekDay = 1
            }
            if sureType == false {
                if i < currentDayItem.day {
                    today = .before
                } else if i > currentDayItem.day {
                    today = .later
                } else {
                    today = .today
                    currentDayItem.row = weeks.count;
                }
            }
            let item = FMCalendarDayItem(year: year, month: month, day: i, weekDay: dayWeek, dayType: today, select: false, other: [String:Any]())
            days.append(item)
            dayWeek += 1
            if i == count {
                weeks.append(FMCalendarWeekItem(year: year, month: month, startDay: startWeekDay, days: days))
            }
        }
        return FMCalendarMonthItem(year: year, month: month, weeks: weeks)
    }
    
    class func getDaysCount(year: Int, month: Int) -> Int {
        formatter.dateFormat = "yyyy-MM"
        let date = formatter.date(from: "\(year)-\(month)")
        let dayCount = calendar.range(of: .day, in: .month, for: date!)
        return dayCount!.count
    }
}
