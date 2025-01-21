//
//  NMCore+WishKit.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 1/21/25.
//

import WishKit

extension NMCore {
    static let wishKitPublicAPIKey = "BD705F6E-874D-46B4-8D6F-AFB5F3EB6585"
    
    static func configureWishKit() {
        WishKit.configure(with: wishKitPublicAPIKey)
    }
}
