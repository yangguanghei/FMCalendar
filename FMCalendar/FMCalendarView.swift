//
//  FMCalendarView.swift
//  YueYouHui
//
//  Created by 周发明 on 2018/9/6.
//

import UIKit

@objc protocol FMCalendarViewProtocol {
    
    func clickDayItem(_ item: FMCalendarDayItem) -> Void
    
    func handleWillShow(_ dayItem: FMCalendarDayItem) -> ()
    
    @objc optional
    func configurationColl(_ collectionView: UICollectionView) -> ()
}


class FMCalendarView: UIView {
    
    fileprivate let dateRange: CountableClosedRange<Int>
    fileprivate let itemHeight: CGFloat
    fileprivate let width: CGFloat
    
    var delegate: FMCalendarViewProtocol? = nil
    
    var currentSelectDay: FMCalendarDayItem? = nil {
        didSet {
            oldValue?.select = false
            currentSelectDay?.select = true
            self.dateColl.reloadData()
        }
    }
    
    /// 根据日期范围创建
    /// - Parameters:
    ///   - dateRange: 从当前月往前往后推可选几个月
    ///   - width: 当前控件宽度
    ///   - itemHeight: 每一个Item的高度
    ///   - delegate: 回调代理
    init(dateRange: CountableClosedRange<Int>, width: CGFloat, itemHeight: CGFloat, delegate: FMCalendarViewProtocol? = nil) {
        
        self.dateRange = dateRange
        self.itemHeight = itemHeight
        self.width = width
        self.delegate = delegate
        
        super.init(frame: CGRect())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() -> Void {
        self.dateColl.reloadData()
    }
    
    fileprivate lazy var dateColl: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.width, height: self.itemHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.headerReferenceSize = CGSize(width: self.width, height: 40)
        let coll = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        coll.backgroundColor = UIColor.white
        coll.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        coll.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "UICollectionReusableView")
        coll.delegate = self
        coll.dataSource = self
        self.addSubview(coll)
        return coll
    }()
    
    fileprivate lazy var months: [FMCalendarMonthItem] = {
        return FMCalendarData.getData(self.dateRange)
    }()
}


extension FMCalendarView: UICollectionViewDelegate, UICollectionViewDataSource, FMCalendarCellViewProtocol{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dateColl.frame = self.bounds
        self.delegate?.configurationColl?(self.dateColl)
        
        self.dateColl.scrollToItem(at: IndexPath(item: FMCalendarData.currentDayItem.row, section: 0), at: .centeredVertically, animated: false)
    }
    
    func cellViewItemClick(_ itemView: FMCalendarCellDayView) {
        if itemView.item!.canSelect {
            self.currentSelectDay = itemView.item
            self.delegate?.clickDayItem(itemView.item!)
        }
    }
    
    func handleWillShow(_ dayItem: FMCalendarDayItem) {
        self.delegate?.handleWillShow(dayItem)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let monthItem = self.months[section]
        return monthItem.weeks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        
        let tag: Int = 100
        var cellView = cell.contentView.viewWithTag(tag)
        if cellView == nil {
            let view = FMCalendarCellView()
            view.delegate = self
            cell.contentView.addSubview(view)
            view.tag = tag
            cellView = view
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let tag: Int = 100
        let cellView = cell.contentView.viewWithTag(tag)
        cellView?.frame = cell.contentView.bounds
        if indexPath.section < self.months.count {
            let month = self.months[indexPath.section]
            if indexPath.row < month.weeks.count {
                let week = month.weeks[indexPath.row]
                (cellView as! FMCalendarCellView).week = week
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "UICollectionReusableView", for: indexPath)
            header.backgroundColor = UIColor.cyan
            let tag: Int = 100
            var label = header.viewWithTag(tag)
            if label == nil {
                let  inLabel = UILabel()
                inLabel.tag = tag
                inLabel.font = UIFont.systemFont(ofSize: 13)
                inLabel.textColor = UIColor.black
                header.addSubview(inLabel)
                inLabel.frame = CGRect(x: 0, y: 0, width: self.width, height: 40);
                label = inLabel
            }
            let monthItem = self.months[indexPath.section]
            (label as! UILabel).text = "\(monthItem.year)年\(monthItem.month)月"
            return header
        } else {
            return UICollectionReusableView()
        }
    }
}

