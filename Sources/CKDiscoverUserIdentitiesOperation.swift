//
//  CKDiscoverUserIdentitiesOperation.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 14/07/2016.
//
//

import Foundation

public class CKDiscoverUserIdentitiesOperation : CKOperation {
    
    
    public override init() {
        userIdentityLookupInfos = []
        super.init()
    }
    
    public convenience init(userIdentityLookupInfos: [CKUserIdentityLookupInfo]) {
        self.init()
        self.userIdentityLookupInfos = userIdentityLookupInfos
    }
    
    public var userIdentityLookupInfos: [CKUserIdentityLookupInfo]
    
    public var userIdentityDiscoveredBlock: ((CKUserIdentity, CKUserIdentityLookupInfo) -> Swift.Void)?
    
    public var discoverUserIdentitiesCompletionBlock: ((Error?) -> Swift.Void)?
    
    override func finishOnCallbackQueue(error: Error?) {
        
        self.discoverUserIdentitiesCompletionBlock?(error)
        
        super.finishOnCallbackQueue(error: error)
        
    }
    
    override func performCKOperation() {
        
        let url = "\(databaseURL)/public/users/discover"
        let lookUpInfos = userIdentityLookupInfos.map { (lookupInfo) -> [String: Any] in
            return lookupInfo.dictionary
        }
        
        let request: [String: Any] = ["lookupInfos": lookUpInfos.bridge() as Any]
        
        urlSessionTask = CKWebRequest(container: operationContainer).request(withURL: url, parameters: request) { (dictionary, error) in
            
            // Check if cancelled
            // (should no longer be needed)
//            if self.isCancelled {
//                // Send Cancelled Error to CompletionBlock
//                let cancelError = NSError(domain: CKErrorDomain, code: CKErrorCode.OperationCancelled.rawValue, userInfo: nil)
//                self.finishOnCallbackQueue(error: cancelError)
//            }
            
            if let error = error {
                self.finish(error: error)
                return
            } else if let dictionary = dictionary {
                // Process Records
                if let userDictionaries = dictionary["users"] as? [[String: Any]] {
                    // Parse JSON into CKRecords
                    for userDictionary in userDictionaries {
                        
                        if let userIdenity = CKUserIdentity(dictionary: userDictionary) {
                            
                            // Call RecordCallback
                            self.userIdentityDiscoveredBlock?(userIdenity, userIdenity.lookupInfo!)
                            
                        } else {
                            
                            // Create Error
                            let error = NSError(domain: CKErrorDomain, code: CKErrorCode.PartialFailure.rawValue, userInfo: [NSLocalizedDescriptionKey: "Failed to parse record from server"])
                            // Call RecordCallback
                            self.finish(error: error)
                            return
                        }
                    }
                }
            }
            // Mark operation as complete
            self.finish(error: nil)
        }
    }
}
