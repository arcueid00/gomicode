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

    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print( getMediaNum())
        medias = getMedias()
        

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func getMediaNum() -> Int
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

        let dbQueue = try! AppDatabase.openDatabase(atPath: databaseURL.path)
//        let dbQueue = try! DatabaseQueue(path: databaseURL.path,configuration: config)

        let mediaCount = try! dbQueue.read{ db in
            try Media.fetchCount(db)
        }
        return mediaCount
    }
    
    func getMedias() -> [Media]
    {
        let databaseURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("media.db")

        var config = Configuration()
        config.readonly = true
        config.foreignKeysEnabled = true // Default is already true
        config.trace = { print($0) }     // Prints all SQL statements
        config.label = "MyDatabase"      // Useful when your app opens multiple databases
        
        let dbQueue = try! DatabaseQueue(path: databaseURL.path,configuration: config)

        let medias = try! dbQueue.read{ db in
            try Media.fetchAll(db)
        }
        return medias
    }
    

    func numberOfRows(in tableView: NSTableView) -> Int {
        return medias.count
    }
    
    func tableView(_ tableView : NSTableView, objectValueFor tableColumn : NSTableColumn?,row:Int) -> Any?
    {
        print((tableColumn?.identifier)!.rawValue)
        
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
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

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
                let imageView = NSImageView(frame:NSRect(x: 0, y: 0, width: 600, height:320))
                imageView.image = image
                cell.addSubview(imageView)
            }
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return 320+8;
    }


}

