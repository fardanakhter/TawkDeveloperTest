//
//  Tawk_Practice_Detail_Unit_Test.swift
//  Tawk Practice Unit Tests
//
//  Created by Fardan Akhter on 30/08/2021.
//

import XCTest
import CoreData
@testable import Tawk_Practice_Test

class Tawk_Practice_Detail_Unit_Test: XCTestCase {

    // System Under Test
    var sut: CDUserModel!
    var sutViewModelProvider: ListDetailViewModelProvider!
    var coreDataManager: CDManager!
    var viewController: DetailViewController!
    var service: DetailViewControllerService!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sutViewModelProvider = ListDetailViewModelProvider(username: "")
        coreDataManager = CDManager(entity: .user)
        viewController = ViewControllerManager.instance.getDetailViewController() as! DetailViewController
        service = DetailViewControllerService.shared
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        // delete test data from database
        if sut != nil {
            coreDataManager.deleteDatabaseModel(model: sut)
            sut = nil
        }
        
        sutViewModelProvider = nil
        coreDataManager = nil
        service = nil
        viewController = nil

        try super.tearDownWithError()
    }

    // Test Profile API Response
    func testProfileAPIResponseWithSuccessAndNonEmptyData(){
        
        XCTAssertNil(sut, "Data Model must be nil before API call")
        
        // given
        let usernameToGetProfile = "mojombo"
        let promise = expectation(description: "API response with status true !")
        
        // when
        var responseSuccess: Bool!
        self.service.getUserDetail(username: usernameToGetProfile) { model, status in
            responseSuccess = status
            self.sut = model
            promise.fulfill()
        }
        wait(for: [promise], timeout: 2.0) // API Timeout 
        
        // then
        XCTAssertEqual(responseSuccess, true, "Error from API call !")
        XCTAssertNotNil(sut, "Nil Object from API !")
    }
    
    // Test Data Parsing
    func testDataParsingFromMockAPIResponse() throws {
        
        XCTAssertNil(sut, "Data Model must be nil before API call")
        
        // given
        let mockAPIResponseData = """
            {
              "login": "mojombo",
              "id": 9743939,
              "node_id": "MDEyOk9yZ2FuaXphdGlvbjk3NDM5Mzk=",
              "avatar_url": "https://avatars.githubusercontent.com/u/9743939?v=4",
              "gravatar_id": "",
              "url": "https://api.github.com/users/tawk",
              "html_url": "https://github.com/tawk",
              "followers_url": "https://api.github.com/users/tawk/followers",
              "following_url": "https://api.github.com/users/tawk/following{/other_user}",
              "gists_url": "https://api.github.com/users/tawk/gists{/gist_id}",
              "starred_url": "https://api.github.com/users/tawk/starred{/owner}{/repo}",
              "subscriptions_url": "https://api.github.com/users/tawk/subscriptions",
              "organizations_url": "https://api.github.com/users/tawk/orgs",
              "repos_url": "https://api.github.com/users/tawk/repos",
              "events_url": "https://api.github.com/users/tawk/events{/privacy}",
              "received_events_url": "https://api.github.com/users/tawk/received_events",
              "type": "Organization",
              "site_admin": false,
              "name": "tawk.to",
              "company": null,
              "blog": "https://www.tawk.to",
              "location": null,
              "email": null,
              "hireable": null,
              "bio": null,
              "twitter_username": "tawktotawk",
              "public_repos": 31,
              "public_gists": 0,
              "followers": 0,
              "following": 0,
              "created_at": "2014-11-14T12:23:56Z",
              "updated_at": "2021-08-06T09:20:54Z"
            }
            """.data(using: .utf8)
        
        
        try XCTSkipIf(mockAPIResponseData == nil, "Mock Data must not be nil to test")
        
        // when
        sut = try? Router.decodeJsonToCoredata(data: mockAPIResponseData!, decoderType: CDUserModel.self)
        
        // then
        XCTAssertNotNil(sut, "Parsed Data is Nil")
        XCTAssertTrue(sut.login == "mojombo", "Expected Data not Found")
        XCTAssertTrue(sut.blog == "https://www.tawk.to", "Expected Data not Found")
    }
    
    // Test Data Updating
    func testSaveNoteButtonPressAndViewModelCallBacks(){
        
        // given
        let sampleNotesToAdd = "Shark"
        let sampleUserLoginToTest = "tawk"
        
        let netWorkCallbackPromise = expectation(description: "Data Fetch CallBack")
        let savedNoteCallbackPromise = expectation(description: "Note Updated Callback")
        let updatedCallbackPromise = expectation(description: "Data Updated Callback")
        
        sutViewModelProvider = ListDetailViewModelProvider(username: sampleUserLoginToTest)
        viewController.viewModelProvider = sutViewModelProvider
        
        let notesTextView = UITextView()
        notesTextView.text = sampleNotesToAdd
        viewController.notesTextView = notesTextView // simulate notes view
        
        let saveButton = UIButton() // simulate save button usecase on detail page
        saveButton.addTarget(viewController, action: #selector(viewController.saveBtnAction(_:)), for: .touchUpInside)
        
        // when
        var updatedNote: String?
        sutViewModelProvider.networkDataCallBack = { model in
            netWorkCallbackPromise.fulfill()
        }
        sutViewModelProvider.networkCall() // Makes network call
        wait(for: [netWorkCallbackPromise], timeout: 2.0) // waits until data fetch callback received
        
        sutViewModelProvider.savedNoteCallBack = {
            savedNoteCallbackPromise.fulfill()
        }
        saveButton.sendActions(for: .touchUpInside) // this sends tap action on save button
        wait(for: [savedNoteCallbackPromise], timeout: 1.0) // waits until saved data callback received
        
        sutViewModelProvider.networkDataCallBack = { model in
            updatedNote = model.note // updated value fetched
            updatedCallbackPromise.fulfill()
        }
        sutViewModelProvider.networkCall() // Makes network call
        wait(for: [updatedCallbackPromise], timeout: 2.0) // waits until updated data callback received
        
        // then
        XCTAssertEqual(sampleNotesToAdd, updatedNote, "Value not updated successfully")
    }

}
