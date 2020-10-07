//
//  TimerManager.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 10/2/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import Foundation

class TimerManager {
    
    //FOR CLEARING CURRENT PICK EACH WEEK
    
     func setUpTimer() {
        print("SETTING UP TIMER")
        let currentDate = Date()
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: currentDate)
        print("CURRENT DAY: \(currentWeekday)")
        var newDate: Date?
        if currentWeekday >= 3 {
            print("IT IS AFTER TUESDAY")
            let daysUntilTuesday = 7 - (currentWeekday - 3)
            newDate = self.getNextTuesday(days: daysUntilTuesday)
            print("NEXT TUESDAY: \(String(describing: newDate))")
        } else {
            print("IT IS BEFORE TUESDAY")
            let daysUntilTuesday = 3 - currentWeekday
            newDate = self.getNextTuesday(days: daysUntilTuesday)
            print("NEXT TUESDAY: \(String(describing: newDate))")
        }
        guard let nextTuesday = newDate else { return }
        self.initilizeTimer(date: nextTuesday)
    }
    
    private func initilizeTimer(date: Date) {
        let timer = Timer(fireAt: date, interval: 604800, target: self, selector: #selector(resetPicks), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    
   private func getNextTuesday(days: Int) -> Date? {
        let currentDate = Date()
        guard let newDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate, wrappingComponents: false) else { return nil }
        let nextTuesday = Calendar.current.date(bySettingHour: 22, minute: 00, second: 00, of: newDate)
        return nextTuesday
    }
    
    @objc private func resetPicks() {
        Picks.store.removeCurrentPick()
        FirebaseClient.removeCurrentPick()
    }
}
