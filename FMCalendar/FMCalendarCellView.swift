//
//  FMCalendarCellView.swift
//  YueYouHui
//
//  Created by 周发明 on 2018/9/6.
//

import UIKit

class FMCalendarCellDayView: UIView {
    static let dontSelect: UIColor = UIColor.lightGray
    static let canSelect: UIColor = UIColor.red
    var item: FMCalendarDayItem? = nil {
        didSet {
            if item != nil {
                self.day.text = "\(item!.day)"
                switch item!.dayType {
                case .today:
                    self.day.text = "今天"
                    if item!.canSelect {
                       self.day.textColor = UIColor.black
                    } else {
                        self.day.textColor = (item!.weekDay == 1 || item!.weekDay == 7) ? FMCalendarCellDayView.dontSelect : FMCalendarCellDayView.canSelect
                    }
                    break
                case .before:
                    self.day.textColor = (item!.weekDay == 1 || item!.weekDay == 7) ? FMCalendarCellDayView.dontSelect : FMCalendarCellDayView.canSelect
                    break
                case .later:
                    if item!.canSelect {
                        self.day.textColor = UIColor.black
                    } else {
                        self.day.textColor = (item!.weekDay == 1 || item!.weekDay == 7) ? FMCalendarCellDayView.dontSelect : FMCalendarCellDayView.canSelect
                    }
                    break
                }
                
                if item!.select {
                    self.day.textColor = UIColor.white
                    self.backgroundColor = UIColor.orange
                } else {
                    self.backgroundColor = UIColor.white
                }
                
                self.money.text = item?.bottom
                
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
//        self.fm_radius(4)
//
//        self.day.makeConstraint { (make) in
//            make.centerX.equalTo(self)
//            make.centerY.equalTo(self).constant(-5)
//        }
//
//        self.money.makeConstraint { (make) in
//            make.centerX.equalTo(self)
//            make.bottom.equalTo(self).constant(-12)
//        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var day: UILabel = {
        let label = UILabel()
        label.textAlignment = .center;
        label.font = UIFont.boldSystemFont(ofSize: 14)
        self.addSubview(label)
        return label
    }()
    
    lazy var money: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
//        label.textColor = UIColor.hex(0xFE1363)
        label.text = ""
        self.addSubview(label)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.day.frame = self.bounds;
    }
}


protocol FMCalendarCellViewProtocol {
    func cellViewItemClick(_ itemView: FMCalendarCellDayView)
    func handleWillShow(_ dayItem: FMCalendarDayItem)
}

class FMCalendarCellView: UIView {
    var delegate: FMCalendarCellViewProtocol? = nil
    var week: FMCalendarWeekItem? = nil {
        didSet {
            if week == nil {
                self.dayViews.forEach { (view) in
                    view.isHidden = true
                }
            } else {
                var index = 1
                for view in self.dayViews {
                    if index < week!.startDay {
                        view.isHidden = true
                    } else {
                        let dayIndex = index - week!.startDay
                        if dayIndex < week!.days.count {
                            view.isHidden = false
                            self.delegate?.handleWillShow(week!.days[dayIndex])
                            view.item = week!.days[dayIndex]
                        } else {
                            view.isHidden = true
                        }
                    }
                    index += 1
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.dayViews.forEach { (view) in
            self.addSubview(view)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func itemViewTap(_ tap: UITapGestureRecognizer) -> Void {
        let view = tap.view as! FMCalendarCellDayView
        self.delegate?.cellViewItemClick(view)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.bounds.width / CGFloat(self.dayViews.count)
        let height = self.bounds.height
        var index: CGFloat = 0
        for view in self.dayViews {
            view.frame = CGRect(x: index * width, y: 0, width: width, height: height)
            index += 1
        }
    }
    
    lazy var dayViews: [FMCalendarCellDayView] = {
        var views = [FMCalendarCellDayView]()
        for i in 100..<107 {
            let view = FMCalendarCellDayView()
            view.tag = i
            let tap = UITapGestureRecognizer(target: self, action: #selector(FMCalendarCellView.itemViewTap(_:)))
            view.addGestureRecognizer(tap)
            views.append(view)
        }
        return views
    }()
}
