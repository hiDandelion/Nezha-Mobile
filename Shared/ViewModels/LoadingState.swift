//
//  LoadingState.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 12/1/24.
//

enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}
