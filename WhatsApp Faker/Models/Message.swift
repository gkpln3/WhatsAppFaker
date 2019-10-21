//
//  Chat.swift
//  WhatsApp Faker
//
//  Created by Guy Kaplan on 05/11/2018.
//  Copyright © 2018 Guy Kaplan. All rights reserved.
//

import Foundation
import SQLite



class Message
{
    public static let id = Expression<Int64>("Z_PK")
    public static let text = Expression<String?>("ZTEXT")
    public static let isFromMe = Expression<Int64?>("ZISFROMME")
    public static let status = Expression<Int64?>("ZMESSAGESTATUS")
    public static let sentDate = Expression<Double?>("ZSENTDATE")
    public static let messageDateInt = Expression<Int64?>("ZMESSAGEDATE")
    public static let messageDateFloat = Expression<Float64?>("ZMESSAGEDATE")
    public static let timestampOffset: TimeInterval = 978307200 // Offset of whatsapp timestamp from unix timestamp.
    
    enum MessageStatus
    {
        case Sent
        case Delivered
        case Read
    }
    
    var id: Int64
    var content: String?
    var isFromMe: Bool
    var status: MessageStatus
    var date: Date?
    
    // Init the chat object from a row
    init(_ row: Row)
    {
        self.id = row[Message.id]
        self.content = row[Message.text]
        self.isFromMe = (row[Message.isFromMe] == 1)
        
        if (row[Message.messageDateFloat] != nil)
        {
            self.date = Date(timeIntervalSince1970: ((row[Message.messageDateFloat]!) + Message.timestampOffset))
        }
        else
        {
            self.date = Date(timeIntervalSince1970: (Double((row[Message.messageDateInt]!)) + Message.timestampOffset))
        }
        
        switch (row[Message.status])
        {
        case 8:
            self.status = .Delivered
            break
            
        case 6:
            self.status = .Read
            break
            
        default:
            self.status = .Sent
            break
        }
    }
    
    func getUpdate() -> [Setter]
    {
        var status: Int64 = 0
        switch (self.status)
        {
        case .Delivered:
            status = 10
        case .Sent:
            status = 2
        case .Read:
            status = 6
        }
        
        // Return an array of setters.
        return [Message.text <- self.content,
                Message.isFromMe <- (self.isFromMe ? 1 : 0),
                Message.status <- status,
                Message.sentDate <- (self.date?.timeIntervalSince1970)! - Message.timestampOffset,
                Message.messageDateFloat <- (self.date?.timeIntervalSince1970)! - Message.timestampOffset
        ]
    }
    

    
    public var description: String { return "Message - id: \(self.id), content: \(self.content ?? "")" }
}
