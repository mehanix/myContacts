//
//  ThisDayInHistory.swift
//  MyContacts
//
//  Created by user216341 on 5/7/22.
//

import Foundation

struct ThisDayInHistory: Codable {
    var date: String;
    var url: String;
    var data: DataCodable;
}

struct DataCodable: Codable {
    var Events: [InfoData];
    var Births: [InfoData];
    var Deaths: [InfoData];
}

struct InfoData: Codable {
    var year: String;
    var text: String;
    var html: String;
    var no_year_html: String;
    var links: [LinkData]
}

struct LinkData: Codable {
    var title: String;
    var link: String;
}
