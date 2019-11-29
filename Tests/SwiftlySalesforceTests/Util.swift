import Foundation
import SwiftlySalesforce

struct Util {
    
    static let connectedApp: ConnectedApp = {
        let consumerKey = "3MVG9A2kN3Bn17huXyIWhPTaZP_9bNv_nCFX1Ob6BDcmWPloGHT89GJkTfZBu1nZekqtmjxgZTSELn7eEVMRC"
        let callbackURL = URL(string: "testapp://oauthdone")!
        return ConnectedApp(consumerKey: consumerKey, callbackURL: callbackURL)
    }()
    
    static let salesforce: Salesforce = {
        return Salesforce(connectedApp: Util.connectedApp)
    }()
}
