//
//  PlannerUITests.swift
//  PlannerUITests
//
//  Created by Andrea Clare Lam on 30/12/2020.
//  Copyright © 2020 Andrea Clare Lam. All rights reserved.
//

import XCTest

class PlannerUITests: XCTestCase {
    
    let numberToMonthShort = [1: "Jan", 2: "Feb", 3: "Mar", 4: "Apr", 5: "May", 6: "Jun", 7: "Jul", 8: "Aug", 9: "Sep", 10: "Oct", 11: "Nov", 12: "Dec"]
    let numberToMonthLong = [1: "January", 2: "February", 3: "March", 4: "April", 5: "May", 6: "June", 7: "July", 8: "August", 9: "Septempber", 10: "October", 11: "November", 12: "December"]

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testValidNewCanvasWhenDateSelected() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        let currentDate = getCurrentDate()
        let currentDay = currentDate.0
        let currentMonth = currentDate.1
        let currentYear = currentDate.2
        
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 3).collectionViews.children(matching: .cell).element(boundBy: currentDay).staticTexts["\(currentDay)"].tap()

        let correctDisplayedDate = "\(numberToMonthShort[currentMonth]!) \(currentDay), \(currentYear)"
        XCTAssertTrue(app.staticTexts["\(correctDisplayedDate)"].exists)
        app.navigationBars["Planner.CanvasView"].buttons["Back"].tap()
    }
    
    func testValidNeighbouringMonths () throws {
        
        let app = XCUIApplication()
        app.launch()
        
        let currentDate = getCurrentDate()
        let currentYear = currentDate.2
        let currentMonth = currentDate.1
        
        let collectionViewsQuery = app.collectionViews
        let currentMonthStaticText = collectionViewsQuery.staticTexts["\(numberToMonthLong[currentMonth]!) \(currentYear)"]
                
        XCTAssertTrue(currentMonthStaticText.exists)
        
        currentMonthStaticText.swipeLeft()
        
        var nextMonthNum = currentMonth + 1
        var nextYear = currentYear
        
        if (nextMonthNum == 13) {
            nextMonthNum = 1
            nextYear += 1
        }
        
        let nextMonthStaticText = collectionViewsQuery.staticTexts["\(numberToMonthLong[nextMonthNum]!) \(nextYear)"]
        XCTAssertTrue(nextMonthStaticText.exists)
        
        nextMonthStaticText.swipeRight()
        XCTAssertTrue(currentMonthStaticText.exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    
    /* --------------------------------- */
    /* -------- Other Functions -------- */
    /* --------------------------------- */
    
    func getCurrentDate() -> (Int, Int, Int) {
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let currentYear =  components.year!
        let currentMonth = components.month!
        let currentDay = components.day!
        
        return (currentDay, currentMonth, currentYear)
    }
    
}
