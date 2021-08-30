//
//  Tawk_Practice_List_Unit_test.swift
//  Tawk Practice Unit Tests
//
//  Created by Fardan Akhter on 30/08/2021.
//

import XCTest
import CoreData
@testable import Tawk_Practice_Test

fileprivate final class MockUserModelTester{
    static var mockUserModel: CDUserModel?
    private init(){}
    static func createData(manager: CDManager, login: String, note: String){
        mockUserModel = CDUserModel(context: manager.context)
        mockUserModel!.login = login
        mockUserModel!.note = note
        manager.addDatabaseModel(model: mockUserModel!) // Addition of mock data model in coredata to search
    }
}


class Tawk_Practice_List_Unit_Test: XCTestCase {
    
    // System Under Test
    var sut: [CDUserModel]!
    var sutViewModelProvider: ListViewModelProvider!
    var coreDataManager: CDManager!
    var service: ListViewControllerServices!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = [CDUserModel]()
        sutViewModelProvider = ListViewModelProvider()
        coreDataManager = CDManager(entity: .user)
        service = ListViewControllerServices.shared
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        // delete mock data from database
        if let mockData = MockUserModelTester.mockUserModel{
            coreDataManager.deleteDatabaseModel(model: mockData)
        }
        
        // delete test data from database
        if !sut.isEmpty {
            sut.forEach { models in
                coreDataManager.deleteDatabaseModel(model: models)
            }
        }
        
        sut = nil
        sutViewModelProvider = nil
        coreDataManager = nil
        service = nil

        try super.tearDownWithError()
    }
    
    // Test API Response
    func testListAPIResponseWithSuccessAndNonEmptyData(){
        
        XCTAssertEqual(sut.count, 0, "Data model list must be zero before API call !")
        
        // given
        let promise = expectation(description: "API response with status true !")
        
        // when
        var responseSuccess: Bool!
        self.service.getListOfUsers(page: 0) { models, status in
            responseSuccess = status
            self.sut = models
            promise.fulfill()
        }
        wait(for: [promise], timeout: 2) // API Timeout of 2 sec
        
        // then
        XCTAssertEqual(responseSuccess, true, "Error from API call !")
        XCTAssertEqual(sut.isEmpty, false, "No Data from API !")
    }
    
    // Test Data Parsing
    func testDataParsingFromMockAPIResponse() throws {
        
        XCTAssertEqual(sut.count, 0, "Data model list must be zero before API call")
        
        // given
        let mockAPIResponseData = """
            [
              {
                "login": "mojombo",
                "id": 1,
                "node_id": "MDQ6VXNlcjE=",
                "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
                "gravatar_id": "",
                "url": "https://api.github.com/users/mojombo",
                "html_url": "https://github.com/mojombo",
                "followers_url": "https://api.github.com/users/mojombo/followers",
                "following_url": "https://api.github.com/users/mojombo/following{/other_user}",
                "gists_url": "https://api.github.com/users/mojombo/gists{/gist_id}",
                "starred_url": "https://api.github.com/users/mojombo/starred{/owner}{/repo}",
                "subscriptions_url": "https://api.github.com/users/mojombo/subscriptions",
                "organizations_url": "https://api.github.com/users/mojombo/orgs",
                "repos_url": "https://api.github.com/users/mojombo/repos",
                "events_url": "https://api.github.com/users/mojombo/events{/privacy}",
                "received_events_url": "https://api.github.com/users/mojombo/received_events",
                "type": "User",
                "site_admin": false
              },
            {
                "login": "defunkt",
                "id": 2,
                "node_id": "MDQ6VXNlcjI=",
                "avatar_url": "https://avatars.githubusercontent.com/u/2?v=4",
                "gravatar_id": "",
                "url": "https://api.github.com/users/defunkt",
                "html_url": "https://github.com/defunkt",
                "followers_url": "https://api.github.com/users/defunkt/followers",
                "following_url": "https://api.github.com/users/defunkt/following{/other_user}",
                "gists_url": "https://api.github.com/users/defunkt/gists{/gist_id}",
                "starred_url": "https://api.github.com/users/defunkt/starred{/owner}{/repo}",
                "subscriptions_url": "https://api.github.com/users/defunkt/subscriptions",
                "organizations_url": "https://api.github.com/users/defunkt/orgs",
                "repos_url": "https://api.github.com/users/defunkt/repos",
                "events_url": "https://api.github.com/users/defunkt/events{/privacy}",
                "received_events_url": "https://api.github.com/users/defunkt/received_events",
                "type": "User",
                "site_admin": false
              }
            ]
            """.data(using: .utf8)
        
        
        try XCTSkipIf(mockAPIResponseData == nil, "Mock Data must not be nil to test")
        
        // when
        sut = try? Router.decodeJsonToCoredata(data: mockAPIResponseData!, decoderType: [CDUserModel].self)
        
        // then
        XCTAssertNotNil(sut, "Parsed Data is Nil")
        XCTAssertEqual(sut.count, 2, "Error in Data Parsing")
        XCTAssertTrue(sut.first!.login == "mojombo", "Expected Data not Found at index 0")
        XCTAssertTrue(sut.last!.login == "defunkt", "Expected Data not Found at index 1")
    }
    
    // Test User Search Algorithm
    func testListSearchingLogicOnMockData(){
        
        // given
        let searchText = "test"
        MockUserModelTester.createData(manager: coreDataManager, login: "", note: "TEST")
        let mockUserModelToSearch = MockUserModelTester.mockUserModel
        let promise = expectation(description: "Search callback called!")
        
        // when
        var searchResult: [ListViewModel]? = nil // this will hold result view models from search callback
        sutViewModelProvider.searchedDataCallBack = { models in
            promise.fulfill()
            models?.forEach{ print($0.username) }
            searchResult = models
        }
        
        sutViewModelProvider.didSearchText(text: searchText) // searches data with username/note
        wait(for: [promise], timeout: 1.0)
        
        // then
        XCTAssertEqual(!searchResult!.isEmpty, true, "Empty Results found")
        XCTAssertTrue(searchResult!.first!.username == mockUserModelToSearch!.login , "Unexpected Search results: \(searchResult!.first!.username)")
        
    }
    
}
