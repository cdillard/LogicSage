//
//  ModelsResult.swift
//  
//
//  Created by Aled Samuel on 08/04/2023.
//

import Foundation

public struct ModelsResult: Codable, Equatable {
    
    public let data: [ModelResult]
    public let object: String
}
