import XCTest
@testable import SwiftlySalesforce

class CredentialTests: XCTestCase {
    
    let callbackURL = URL(string: "https://www.customercontactinfo.com/user_callback.jsp#access_token=00Dx0000000BV7z%21AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8&refresh_token=5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ%3D%3D&instance_url=https://yourInstance.salesforce.com&id=https://login.salesforce.com%2Fid%2F00Dx0000000BV7z%2F005x00000012Q9P&issued_at=1278448101416&signature=miQQ1J4sdMPiduBsvyRYPCDozqhe43KRc1i9LmZHR70%3D&scope=id+api+refresh_token&token_type=Bearer&state=mystate")!
    
    let callbackURLWithUnparseableTimestamp = URL(string: "https://www.customercontactinfo.com/user_callback.jsp#access_token=00Dx0000000BV7z%21AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8&refresh_token=5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ%3D%3D&instance_url=https://yourInstance.salesforce.com&id=https://login.salesforce.com%2Fid%2F00Dx0000000BV7z%2F005x00000012Q9P&issued_at=1278448101416____&signature=miQQ1J4sdMPiduBsvyRYPCDozqhe43KRc1i9LmZHR70%3D&scope=id+api+refresh_token&token_type=Bearer&state=mystate")!
    
    let refreshTokenFlowResponseBody = "access_token=00Dx0000000BV7z%21AR8AQP0jITN80ESEsj5EbaZTFG0RNBaT1cyWk7TrqoDjoNIWQ2ME_sTZzBjfmOE6zMHq6y8PIW4eWze9JksNEkWUl.Cju7m4&token_type=Bearer&scope=id%20api%20refresh_token&instance_url=https%3A%2F%2FyourInstance.salesforce.com&id=https://login.salesforce.com%2Fid%2F00Dx0000000BV7z%2F005x00000012Q9P&issued_at=1278448101416&signature=CMJ4l%2BCCaPQiKjoOEwEig9H4wqhpuLSk4J2urAe%2BfVg%3D"
    
    func testThatItInitializesFromCallbackURL() throws {
        
        // Given
        let fragment = callbackURL.fragment!
        
        // When
        let cred = Credential(fromPercentEncoded: fragment)!
        
        // Then
        XCTAssertEqual(cred.accessToken, "00Dx0000000BV7z!AR8AQBM8J_xr9kLqmZIRyQxZgLcM4HVi41aGtW0qW3JCzf5xdTGGGSoVim8FfJkZEqxbjaFbberKGk8v8AnYrvChG4qJbQo8")
        XCTAssertEqual(cred.refreshToken, "5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ==")
        XCTAssertEqual(cred.instanceURL, URL(string: "https://yourInstance.salesforce.com")!)
        XCTAssertEqual(cred.identityURL, URL(string: "https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P")!)
        XCTAssertEqual(cred.timestamp, Date(timeIntervalSince1970: 1278448101416/1_000))
        XCTAssertNil(cred.siteID)
        XCTAssertNil(cred.siteURL)
        XCTAssertEqual(cred.userID, "005x00000012Q9P")
        XCTAssertEqual(cred.orgID, "00Dx0000000BV7z")
    }
    
    func testThatItFailsToIniatilize() throws {
        
        // Given
        let fragment = callbackURLWithUnparseableTimestamp.fragment!
        
        // When
        let cred = Credential(fromPercentEncoded: fragment)
        
        // Then
        XCTAssertNil(cred)
    }
    
    func testThatItInitializesFromRefreshTokenFlowResponseBody() throws {
        
        // Given
        let refreshToken = "5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_pZfVti1dPEk8aimw4Hr9ne7VXXVSIQ=="
        
        // When
        let cred = Credential(fromPercentEncoded: refreshTokenFlowResponseBody, andRefreshToken: refreshToken)!
        
        // Then
        XCTAssertEqual(cred.accessToken, "00Dx0000000BV7z!AR8AQP0jITN80ESEsj5EbaZTFG0RNBaT1cyWk7TrqoDjoNIWQ2ME_sTZzBjfmOE6zMHq6y8PIW4eWze9JksNEkWUl.Cju7m4")
        XCTAssertEqual(cred.refreshToken, refreshToken)
        XCTAssertEqual(cred.instanceURL, URL(string: "https://yourInstance.salesforce.com")!)
        XCTAssertEqual(cred.identityURL, URL(string: "https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P")!)
        XCTAssertEqual(cred.timestamp, Date(timeIntervalSince1970: 1278448101416/1_000))
        XCTAssertNil(cred.siteID)
        XCTAssertNil(cred.siteURL)
        XCTAssertEqual(cred.userID, "005x00000012Q9P")
        XCTAssertEqual(cred.orgID, "00Dx0000000BV7z")
    }
}
