//
//  LaunchLibraryNetworkTests.swift
//  LaunchLibraryTests
//
//  Created by Sam Beedell on 23/01/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import XCTest
@testable import LaunchLibrary

class LaunchLibraryNetworkTests: XCTestCase {
    
    var sessionUnderTest: URLSession!
    var rocket : Rocket!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sessionUnderTest = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sessionUnderTest = nil
        rocket = nil
        super.tearDown()
    }
    
    // Asynchronous test
    func testCallToLaunchLibrary() {
        // given
        let url = URL(string: "https://launchlibrary.net/1.3/launch?next=5")
        // 1
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        // when
        let dataTask = sessionUnderTest.dataTask(with: url!) { data, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            // 2
            promise.fulfill()
        }
        dataTask.resume()
        // 3
        waitForExpectations(timeout: 5, handler: nil)
        
        // then
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }
    
    // Performance
    func testImageDownload() {
        
        measure {
            self.rocket = Rocket(id: 1234, name: "Testing", agencies: [["Test":"obj" as AnyObject]], imageURL: "https://s3.amazonaws.com/launchlibrary/RocketImages/placeholder_1920.png")
        }
    }
    
}




/*

// Extra Data


// Rocket Launch

{
 id = 1493;
 inhold = 0;
 isoend = 20180125T055100Z;
 isonet = 20180125T053100Z;
 isostart = 20180125T053100Z;
 location =     {
 countryCode = CHN;
 id = 25;
 infoURL = "";
 name = "Xichang Satellite Launch Center, People's Republic of China";
 pads =         (
 {
 agencies =                 (
 {
     abbrev = CNSA;
     countryCode = CHN;
     id = 17;
     infoURL = "http://www.cnsa.gov.cn/";
     infoURLs =                         (
     "http://www.cnsa.gov.cn/"
     );
     name = "China National Space Administration";
     type = 1;
     wikiURL = "http://en.wikipedia.org/wiki/China_National_Space_Administration";
     }
     );
     id = 143;
     infoURL = "<null>";
     latitude = "28.246017";
     longitude = "102.026556";
     mapURL = "https://www.google.com/maps/?q=28.246017,102.026556";
     name = "Launch Complex 3 ( LC-3 ) ( LA-1 ), Xichang Satellite Launch Center";
     wikiURL = "https://en.wikipedia.org/wiki/Xichang_Satellite_Launch_Center";
     }
 );
 wikiURL = "";
 };
 lsp =     {
 abbrev = CASC;
 countryCode = CHN;
 id = 88;
 infoURL = "<null>";
 infoURLs =         (
     "http://english.spacechina.com/",
     "http://www.cast.cn/item/list.asp?id=1561"
 );
 name = "China Aerospace Science and Technology Corporation";
 type = 1;
 wikiURL = "https://en.wikipedia.org/wiki/China_Aerospace_Science_and_Technology_Corporation";
 };
 missions =     (
 {
 agencies = "<null>";
 description = "Yaogan is a series of Chinese reconnaissance satellites.";
 id = 655;
 name = "3 x Yaogan-30";
 type = 7;
 typeName = "Government/Top Secret";
 }
 );
 name = "Long March 2C | 3 x Yaogan-30";
 net = "January 25, 2018 05:31:00 UTC";
 netstamp = 1516858260;
 probability = "-1";
 rocket =     {
     agencies =         (
     {
     abbrev = CASC;
     countryCode = CHN;
     id = 88;
     infoURL = "<null>";
     infoURLs =                 (
     "http://english.spacechina.com/",
     "http://www.cast.cn/item/list.asp?id=1561"
     );
     name = "China Aerospace Science and Technology Corporation";
     type = 1;
     wikiURL = "https://en.wikipedia.org/wiki/China_Aerospace_Science_and_Technology_Corporation";
     }
 );
 configuration = C;
 familyname = "Long March 2";
 id = 75;
 imageSizes =         (
     320,
     480,
     640,
     720,
     768,
     800,
     960,
     1024,
     1080,
     1280,
     1440,
     1920
     );
 imageURL = "https://s3.amazonaws.com/launchlibrary/RocketImages/placeholder_1920.png";
 infoURLs =         (
 );
 name = "Long March 2C";
 wikiURL = "https://en.wikipedia.org/wiki/Long_March_2C";
 };
 status = 1;
 tbddate = 0;
 tbdtime = 0;
 vidURLs =     (
 );
 westamp = 1516859460;
 windowend = "January 25, 2018 05:51:00 UTC";
 windowstart = "January 25, 2018 05:31:00 UTC";
 wsstamp = 1516858260;
 },
};

// Rocket

 rocket =     {
 agencies =         (
 {
 abbrev = CASC;
 countryCode = CHN;
 id = 88;
 infoURL = "<null>";
 infoURLs =                 (
 "http://english.spacechina.com/",
 "http://www.cast.cn/item/list.asp?id=1561"
 );
 name = "China Aerospace Science and Technology Corporation";
 type = 1;
 wikiURL = "https://en.wikipedia.org/wiki/China_Aerospace_Science_and_Technology_Corporation";
 }
 );
 configuration = C;
 familyname = "Long March 2";
 id = 75;
 imageSizes =         (
 320,
 480,
 640,
 720,
 768,
 800,
 960,
 1024,
 1080,
 1280,
 1440,
 1920
 );
 imageURL = "https://s3.amazonaws.com/launchlibrary/RocketImages/placeholder_1920.png";
 infoURLs =         (
 );
 name = "Long March 2C";
 wikiURL = "https://en.wikipedia.org/wiki/Long_March_2C";
};
 
*/
