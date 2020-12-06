//
//  CountryData.swift
//  Search Country
//
//  Created by Анастасия Улитина on 06.12.2020.
//

import Foundation

struct Country: Decodable {
    let name: String
    let alpha3Code: String
    let capital: String
    let borders: [String]
    let nativeName: String
    let currencies: [Currency]
    let languages: [Language]
    let flag: String
}

struct Currency: Decodable {
    let name: String?
    let symbol: String?
}

struct Language: Decodable {
    let name: String
    let nativeName: String
}
