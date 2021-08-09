//
//  Wikipedia API model.swift
//  WhatFlower
//
//  Created by Daniel Ghebrat on 10/05/2021.
//

import Foundation

// MARK: - Welcome
struct WikipediaAPIResponse: Codable {
    let batchcomplete: String
    let query: Query
}

// MARK: - Query
struct Query: Codable {
    let redirects: [Redirect]
    let pages: Pages
}

// MARK: - Pages
struct Pages: Codable {
    let the5920756: The5920756

    enum CodingKeys: String, CodingKey {
        case the5920756 = "5920756"
    }
}

// MARK: - The5920756
struct The5920756: Codable {
    let pageid, ns: Int
    let title, extract: String
}

// MARK: - Redirect
struct Redirect: Codable {
    let from, to: String
}
