//
//  Account.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 23.07.2022.
//

import Foundation

struct Account: Codable {
    let accountNumber: String
    let bankCode: String
    let transparencyFrom: String
    let transparencyTo: String
    let publicationTo: String
    let actualizationDate: String
    let balance: Double
    let currency: String
    let name: String
    let iban: String
    let description: String
    let statements: [String]
    
    enum CodingKeys: String, CodingKey {
        case accountNumber
        case bankCode
        case transparencyFrom	
        case transparencyTo
        case publicationTo
        case actualizationDate
        case balance
        case currency = "currency"
        case name
        case iban
        case description
        case statements
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        accountNumber = try values.decodeIfPresent(String.self, forKey: .accountNumber) ?? ""
        bankCode = try values.decodeIfPresent(String.self, forKey: .bankCode) ?? ""
        transparencyFrom = try values.decodeIfPresent(String.self, forKey: .transparencyFrom) ?? ""
        transparencyTo = try values.decodeIfPresent(String.self, forKey: .transparencyTo) ?? ""
        publicationTo = try values.decodeIfPresent(String.self, forKey: .publicationTo) ?? ""
        actualizationDate = try values.decodeIfPresent(String.self, forKey: .actualizationDate) ?? ""
        balance = try values.decodeIfPresent(Double.self, forKey: .balance) ?? 0.0
        currency = try values.decodeIfPresent(String.self, forKey: .currency) ?? "CZK" // this seems to be default value in my Postman app
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        iban = try values.decodeIfPresent(String.self, forKey: .iban) ?? ""
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        statements = try values.decodeIfPresent([String].self, forKey: .statements) ?? []
    }
}
