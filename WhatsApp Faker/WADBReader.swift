//
//  WADBReader.swift
//  WhatsApp Faker
//
//  Created by Guy Kaplan on 26/10/2018.
//  Copyright © 2018 Guy Kaplan. All rights reserved.
//

import UIKit
import SQLite
import Foundation

class WADBReader {
    static let main = WADBReader()
    
    var db: Connection?
    init()
    {
        guard let fileLocation = findChatStorage() else {
            print("Error - Cant find chat storage file")
            return
        }
        
        if (FileManager.default.fileExists(atPath: fileLocation))
        {
            print("File found! at " + fileLocation)
//            try? FileManager.default.copyItem(at: URL(fileURLWithPath: fileLocation), to: URL(fileURLWithPath: "ChatStorage.sqlite"))
        }

        db = try? Connection(fileLocation)
    }
    
    func findChatStorage() -> String?
    {
        // Check
        let fileLocation = UserDefaults.standard.string(forKey: "chat_storage_location")
        
        if fileLocation != nil
        {
            return fileLocation
        }

        let fileManager = FileManager.default
        let enumerator: FileManager.DirectoryEnumerator? = fileManager.enumerator(atPath: "/private/var/mobile/Containers/Shared/AppGroup/")
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix("ChatStorage.sqlite") {
                
                // Save the location for future use.
                let foundFileLocation = "/private/var/mobile/Containers/Shared/AppGroup/" + element
                UserDefaults.standard.set(foundFileLocation, forKey: "chat_storage_location")
                return foundFileLocation
            }
        }
        
        return nil
    }
    
    func getAllChats() -> [Chat]
    {
        print("Reading chats")
        let msgDate = Expression<String>("ZLASTMESSAGEDATE")
        let chatsTable = Table("ZWACHATSESSION").order(msgDate.desc)
        
        var chatModels: [Chat] = []
        for chatRow in try! self.db!.prepare(chatsTable) {
            chatModels.append(Chat(chatRow))
        }
        
        for chat in chatModels
        {
            print(chat.description)
        }
        return chatModels
    }
    
    func getMessagesForChat(_ chat: Chat) -> [Message]
    {
        print("Reading messgaes")
        let table = Table("ZWAMESSAGE")
        let id = Expression<Int64>("Z_PK")
        let chatId = Expression<Int64?>("ZCHATSESSION")
        
        var models: [Message] = []
        
        let rows = try? self.db!.prepare(table).filter({ (row) -> Bool in
            return row[chatId] == chat.id
        })
        
        
        
        for row in (rows ?? [])
        {
            models.append(Message(row))
        }
        
        for model in models
        {
            print(model.description)
        }
        return models
    }
    
    func updateMessage(_ message: Message)
    {
        let table = Table("ZWAMESSAGE")
        
        // Filter only the message with this ID.
        let messageRow = table.filter(Message.id == message.id)
        
        // Get the update command and run it.
        try! self.db!.run(messageRow.update(message.getUpdate()))
    }
    
    func addMessage(for chat: Chat) -> Message
    {
        let table = Table("ZWAMESSAGE")
        
        // Fill with defaults.
        let insert = table.insert([
            Expression<Int64>("Z_ENT") <- 9,
            Expression<Int64>("Z_OPT") <- 5,
            Expression<Int64>("ZDATAITEMVERSION") <- 3,
            Expression<Int64>("ZCHATSESSION") <- chat.id,
            Expression<Double>("ZMESSAGEDATE") <- Date().timeIntervalSince1970 - Message.timestampOffset
            ])
        let rowid = try! self.db!.run(insert)
        
        let rows = try? self.db!.prepare(table).filter({ (row) -> Bool in
            return row[Message.id] == rowid
        })
        
        return Message(rows![0])
    }
}
