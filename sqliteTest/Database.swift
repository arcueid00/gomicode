//
//  Database.swift
//  sqliteTest
//
//  Created by Katsuhiko Tamura on 2018/10/08.
//  Copyright © 2018年 Katsuhiko Tamura. All rights reserved.
//

import Foundation
import GRDB

class Media : Record
{
    var content_id  : String? = ""
    var product_id : String? = ""
    var title : String? = ""
    var actress:[Actress]? = []
    var url : String? = ""
    var image_url : String? = ""
    var thumbnail : Data? = nil
    var searchWord : String? = ""
    var path : String? = ""
    
    required init(row: Row) {
        self.content_id = row["content_id"]
        self.product_id = row["product_id"]
        self.title = row["title"]
        //self.actress = row["actress"] as! [Actress]
        self.url = row["url"]
        self.image_url = row["image_url"]
        self.thumbnail = row["thumbnail"] as! Data
        self.searchWord = row["searchword"]
        self.path = row["path"]
        super.init(row:row)
    }
    
    override static var databaseTableName : String{
        return "Medias"
    }
}

class Actress : Record
{
    var id : String? = ""
    var name : String? = ""
    var Mediacontent_id : String? = ""
    
    required init(row: Row) {
        self.id = row["id"]
        self.name = row["name"]
        self.Mediacontent_id = row["Mediacontent_id"]
        super.init(row:row)
    }
    
    override static var databaseTableName : String{
        return "Actors"
    }
}

struct AppDatabase{
    static func openDatabase( atPath path : String ) throws ->DatabaseQueue{
        
        var config = Configuration()
        //config.readonly = true
        config.foreignKeysEnabled = true // Default is already true
        config.trace = { print($0) }     // Prints all SQL statements
        config.label = "MyDatabase"      // Useful when your app opens multiple databases

        let dbQueue = try DatabaseQueue( path : path, configuration: config );
        
        //try migrator.migrate(dbQueue)
        
        return dbQueue;
    }
    
    static var migrator : DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("createactress"){ db in
            try db.create(table: "actors"){ t in
                t.column("id", .text).primaryKey()
                t.column("name", .text);
                t.column("Mediacontent_id", .text)
            }
        }
        return migrator;
    }
}



