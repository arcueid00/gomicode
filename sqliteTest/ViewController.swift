//
//  ViewController.swift
//  sqliteTest
//
//  Created by Katsuhiko Tamura on 2018/10/06.
//  Copyright © 2018年 Katsuhiko Tamura. All rights reserved.
//

import Cocoa
import GRDB

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var medias : [Media] = []
    var actors : [Actress] = []

    @IBOutlet weak var existsButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var actotTableView: NSTableView!
    var dbQueue : DatabaseQueue!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbQueue = getDB()

        // Do any additional setup after loading the view.
        print( getMediaNum())
        medias = getExistPathMedias()
        

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func getDB() -> DatabaseQueue
    {
        let databaseURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("media.db")
        
        if( FileManager.default.fileExists( atPath: databaseURL.path ) ) {
            
            print("ファイルあり")
            
        } else {
            
            print("ファイルなし")
            
        }
        
        var config = Configuration()
        config.readonly = true
        config.foreignKeysEnabled = true // Default is already true
        config.trace = { print($0) }     // Prints all SQL statements
        config.label = "MyDatabase"      // Useful when your app opens multiple databases
        
        return try! AppDatabase.openDatabase(atPath: databaseURL.path)
    }
    
    func getMediaNum() -> Int
    {


        let mediaCount = try! dbQueue.read{ db in
            try Media.fetchCount(db)
        }
        return mediaCount
    }
    
    func getMedias() -> [Media]
    {

        let medias = try! dbQueue.read{ db in
            try Media.fetchAll(db)
        }
        return medias
    }

    func getExistPathMedias() -> [Media]
    {
       
        let medias = try! dbQueue.read{ db in
            try Media.filter("path" == "").fetchAll(db)
        }
        return medias
    }
    
    func updateActors(tableViewSelectedRow selectedRow : Int)
    {
        let mediaActors = try! dbQueue.read{ db in
            try MediaActor.filter(Column("content_id") == medias[selectedRow].content_id).fetchAll(db)
        }
        actors.removeAll()
        
        mediaActors.forEach { (mediaActor) in
            if( mediaActor.actor_id?.contains("ruby") == false && mediaActor.actor_id?.contains("classify") == false )
            {
                let result : Actress = (try! dbQueue.read{ db in
                    try Actress.filter(Column("id") == mediaActor.actor_id).fetchOne(db)
                    })!
                actors.append(result)
            }
        }
        print( "Actors=", actors.count)
    }

    
    @IBAction func didPushExistsCheckButton(_ sender: Any) {
        let checkState : Int = existsButton.state.rawValue
        if( checkState == NSControl.StateValue.on.rawValue)
        {
            print("チェックあり")
            medias = getExistPathMedias()
        }
        else
        {
            print("チェックなし")
            medias = getMedias()
        }
        tableView.reloadData()
        actotTableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if( tableView.identifier!.rawValue == "mainTableView")
        {
            print( "テーブル数=", medias.count)
            return medias.count
        }
        return actors.count
    }
    
    func mainTableViewNumberOfRows(in tableView: NSTableView) -> Int {
        print( "テーブル数=", medias.count)
        return medias.count
    }
    
    func mainTableViewRowString(_ tableView : NSTableView, objectValueFor tableColumn : NSTableColumn?,row:Int) -> String?
    {
        if( (tableColumn?.identifier)!.rawValue == "ProductId")
        {
            return medias[row].content_id;
        }
        else if( (tableColumn?.identifier)!.rawValue == "Name")
        {
            return medias[row].title
        }
        return medias[row].path
    }
    
    func mainTableViewRowCell(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var cellIdentifier : String = "PathCell"
        if( (tableColumn?.identifier)!.rawValue == "ProductId")
        {
            cellIdentifier = "ThumbnailCell"
        }
        else if( (tableColumn?.identifier)!.rawValue == "Name")
        {
            cellIdentifier = "NameCell"
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView
        {
            if( cellIdentifier == "ThumbnailCell")
            {
                let image = NSImage( data: medias[row].thumbnail!)
                cell.frame = NSRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: 600, height:320 )
                cell.imageView?.frame = NSRect(x: 0, y: 0, width: 600, height:320)
                cell.imageView?.image = image
            }
            return cell
        }
        return nil
    }
    func mainTableViewCellHeight(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return 328;
    }
    
    func actorTableViewRowString(_ tableView : NSTableView, objectValueFor tableColumn : NSTableColumn?,row:Int) -> String?
    {
        return actors[row].name
    }
    
    func actorTableViewRowCell(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let cellIdentifier : String = "ActorCell"
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView
        return cell
    }
    func actorTableViewCellHeight(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return 20;
    }
    
    func tableView(_ tableView : NSTableView, objectValueFor tableColumn : NSTableColumn?,row:Int) -> Any?
    {
        //print((tableColumn?.identifier)!.rawValue)
        if( tableView.identifier!.rawValue == "mainTableView")
        {
            return mainTableViewRowString( tableView, objectValueFor: tableColumn, row: row)
        }
        return actorTableViewRowString( tableView, objectValueFor: tableColumn, row: row)
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        if( tableView.identifier!.rawValue == "mainTableView")
        {
            return mainTableViewRowCell(tableView, viewFor: tableColumn, row: row)
        }
        return actorTableViewRowCell(tableView, viewFor: tableColumn, row: row)
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        if( tableView.identifier!.rawValue == "mainTableView")
        {
            return mainTableViewCellHeight(tableView, heightOfRow:row)
        }
        return actorTableViewCellHeight(tableView, heightOfRow:row)
    }
    
    func tableViewSelectionIsChanging(_ notification: Notification)
    {
        let index = (notification.object as! NSTableView).selectedRow
        print(index)
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool
    {
        print( "選択前 Select=", row)
        if( tableView.identifier?.rawValue == "mainTableView")
        {
            updateActors(tableViewSelectedRow: row)
            actotTableView.reloadData()
        }
        return true
    }


}

