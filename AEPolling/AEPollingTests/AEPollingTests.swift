//
//  AEPollingTests.swift
//  AEPollingTests
//
//  Created by Marcus O'Shea on 5/26/25.
//

import XCTest
@testable import AEPolling

final class AEPollingTests: XCTestCase {
    
    var authManager: AuthenticationManager!
    var navigationManager: NavigationManager!
    
    override func setUpWithError() throws {
        authManager = AuthenticationManager()
        navigationManager = NavigationManager()
    }
    
    override func tearDownWithError() throws {
        authManager = nil
        navigationManager = nil
    }
    
    func testAuthenticationManagerInitialState() throws {
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertNil(authManager.currentUser)
        XCTAssertFalse(authManager.isLoading)
        XCTAssertNil(authManager.errorMessage)
    }
    
    func testNavigationManagerInitialState() throws {
        XCTAssertEqual(navigationManager.selectedTab, .home)
        XCTAssertFalse(navigationManager.showingSideMenu)
    }
    
    func testNavigationManagerTabNavigation() throws {
        navigationManager.navigate(to: .profile)
        XCTAssertEqual(navigationManager.selectedTab, .profile)
        XCTAssertFalse(navigationManager.showingSideMenu)
        
        navigationManager.navigate(to: .polling)
        XCTAssertEqual(navigationManager.selectedTab, .polling)
    }
    
    func testNavigationManagerSideMenuToggle() throws {
        XCTAssertFalse(navigationManager.showingSideMenu)
        
        navigationManager.toggleSideMenu()
        XCTAssertTrue(navigationManager.showingSideMenu)
        
        navigationManager.toggleSideMenu()
        XCTAssertFalse(navigationManager.showingSideMenu)
    }
    
    func testUserModelFullName() throws {
        let user = User(
            id: 1,
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            pollingOrderId: 123
        )
        
        XCTAssertEqual(user.fullName, "John Doe")
    }
    
    func testPollingOrderCodingKeys() throws {
        let order = PollingOrder(
            id: 123,
            name: "Test Order",
            adminId: 1,
            adminAssistantId: 2
        )
        
        XCTAssertEqual(order.id, 123)
        XCTAssertEqual(order.name, "Test Order")
        XCTAssertEqual(order.adminId, 1)
        XCTAssertEqual(order.adminAssistantId, 2)
    }
    
    func testCandidateModel() throws {
        let candidate = Candidate(
            id: 1,
            name: "John Doe",
            pollingOrderId: 123,
            authToken: "token123",
            watchList: true
        )
        
        XCTAssertEqual(candidate.id, 1)
        XCTAssertEqual(candidate.name, "John Doe")
        XCTAssertEqual(candidate.pollingOrderId, 123)
        XCTAssertEqual(candidate.authToken, "token123")
        XCTAssertTrue(candidate.watchList ?? false)
    }
    
    func testAPIErrorLocalizedDescription() throws {
        let invalidURLError = APIError.invalidURL
        XCTAssertEqual(invalidURLError.errorDescription, "Invalid URL")
        
        let unauthorizedError = APIError.unauthorized
        XCTAssertEqual(unauthorizedError.errorDescription, "Unauthorized access")
        
        let serverError = APIError.serverError(500)
        XCTAssertEqual(serverError.errorDescription, "Server error: 500")
    }
    
    func testPerformanceExample() throws {
        measure {
            for _ in 0..<1000 {
                let _ = User(
                    id: 1,
                    email: "test@example.com",
                    firstName: "John",
                    lastName: "Doe",
                    pollingOrderId: 123
                )
            }
        }
    }
}
