//
//  Chat.swift
//  WhatsApp Faker
//
//  Created by Guy Kaplan on 05/11/2018.
//  Copyright © 2018 Guy Kaplan. All rights reserved.
//

import Foundation
import SQLite

class Chat
{
    public let id: Int64
    public let partnerName: String?
    
    // Init the chat object from a row
    init(_ row: Row)
    {
        let id = Expression<Int64>("Z_PK")
        let name = Expression<String?>("ZPARTNERNAME")
        
        self.id = row[id]
        self.partnerName = row[name]
    }
    
    public var description: String { return "id: \(self.id), name: \(self.partnerName ?? "NULL")" }
}
