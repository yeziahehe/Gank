//
//  HistoryViewController.swift
//  Gank
//
//  Created by 叶帆 on 2017/7/12.
//  Copyright © 2017年 Suzhou Coryphaei Information&Technology Co., Ltd. All rights reserved.
//

import UIKit
import JTAppleCalendar

class HistoryViewController: BaseViewController {
    
    @IBOutlet var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    fileprivate var historyStringArray: [String] = GankUserDefaults.historyDate.value!
    fileprivate var historyDateArray: [Date] = Array<String>().transToDate(GankUserDefaults.historyDate.value!)
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureCalendarView()
        calendarView.selectDates(historyDateArray, triggerSelectionDelegate: false)
        
    }
    
    func configureCalendarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.allowsMultipleSelection = true
        
        calendarView.visibleDates { (visibleDates) in
            SafeDispatch.async { [weak self] in
                self?.calendarView.scrollToSegment(.end, animateScroll: false)
                self?.configureViewOfCalendar(visibleDates: visibleDates)
            }
        }
    }
    
    func configureViewOfCalendar(visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        formatter.dateFormat = "YYYY"
        yearLabel.text = formatter.string(from: date)
        
        formatter.dateFormat = "MM"
        monthLabel.text = formatter.string(from: date).toChineseMonth
    }

}

extension HistoryViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: historyStringArray.last!)!
        let endDate = formatter.date(from: historyStringArray.first!)!
        
        let parameters = ConfigurationParameters(startDate:startDate, endDate:endDate)
        return parameters
    }
}

extension HistoryViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "GankDateCell", for: indexPath) as! GankDateCell
        cell.dayLabel.text = cellState.text
        cell.configure(cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if historyDateArray.contains(date) {
            NotificationCenter.default.post(name: GankConfig.NotificationName.chooseGank, object: date.toString())
            navigationController?.popViewController(animated: true)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        configureViewOfCalendar(visibleDates: visibleDates)
    }
}
