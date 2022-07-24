//
//  AccountTransactions.swift
//  TransparentAccountsViewer
//
//  Created by Josef Antoni on 24.07.2022.
//

import Foundation

// MARK: - Empty
struct AccountTransactions: Codable {
    let pageNumber, pageSize, pageCount, nextPage, recordCount: Int
    let transactions: [Transaction]
}


// MARK: - Transaction
struct Transaction: Codable, Identifiable {
    let id: UUID
    let amount: Amount?
    let type, dueDate, processingDate, typeDescription: String
    let sender: Sender?
    let receiver: Receiver?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        amount = try values.decodeIfPresent(Amount.self, forKey: .amount)
        sender = try values.decodeIfPresent(Sender.self, forKey: .sender)
        receiver = try values.decodeIfPresent(Receiver.self, forKey: .receiver)
        type = try values.decodeIfPresent(String.self, forKey: .type) ?? ""
        dueDate = try values.decodeIfPresent(String.self, forKey: .dueDate) ?? ""
        processingDate = try values.decodeIfPresent(String.self, forKey: .processingDate) ?? ""
        typeDescription = try values.decodeIfPresent(String.self, forKey: .typeDescription) ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case type
        case dueDate
        case processingDate
        case typeDescription
        case sender
        case receiver
    }
}

// MARK: - Amount
struct Amount: Codable {
    let value: Double
    let precision: Int
    let currency: String
}

// MARK: - Receiver
struct Receiver: Codable {
    let accountNumber, bankCode, iban: String
}

// MARK: - Sender
struct Sender: Codable {
    let accountNumber, bankCode, iban: String
}
