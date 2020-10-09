//
//  AppDelegate.swift
//  SongBar
//
//  Created by Kevin Cooper on 10/21/14.
//  Copyright (c) 2014 corpe. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var menu: NSMenu!
    var playbackListner = PlaybackListner()
    private var playbackObserver: NSKeyValueObservation?
    var sysBar: NSStatusItem!

    //magic number
    let variableStatusItemLength: CGFloat = -1;
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        sysBar = NSStatusBar.system.statusItem(withLength: variableStatusItemLength)
        sysBar.menu = menu;
        playbackObserver = playbackListner.observe(\PlaybackListner.menuTitle,
                                options: .new) { (listner, title) in
            self.sysBar.title = title.newValue
        }
        playbackListner.refresh()
    }
    
    func updateStatusBar() {
//        let iTunesPlayerState = iTunes?.value(forKey: "playerState") as! MusicEPlS
//        var spotifyPlayerState = Spotify?.playerState
//
//        switch iTunesPlayerState {
//        case .init(1):
//            print("iTunes is playing")
//        default:
//            print("iTunes is not playing")
//        }
//        let iTunesTrack = iTunes?.currentTrack
//        let spotifyTrack = Spotify?.currentTrack
//        var spotifyName: String?
//        var spotifyArtist: String?
//        if let spotifyTrack: SpotifyTrack = Spotify?.currentTrack {
//            spotifyName = spotifyTrack.name != nil ? spotifyTrack.name : ""
//            spotifyArtist = spotifyTrack.artist != nil ? spotifyTrack.artist : ""
//        }
//
//        let name: String = (track.name != nil) ? track.name : "";
//        let artist: String = (track.artist != nil) ? track.artist : "";
//
//
//
//        if  spotifyArtist != nil && spotifyName != nil{
//            sysBar.title = "\(spotifyName!) - \(spotifyArtist!)"
//            self.lastServiceUsed = Service.spotify
//        }else if artist != "" && name != ""{
//            sysBar.title! = name + " - " + artist;
//            self.lastServiceUsed = Service.iTunes
//        }else{
//            sysBar.title! = "SongBar";
//            self.lastServiceUsed = Service.iTunes
//        }
    }
    
    @objc func updateiTuensFromNotification(aNotification: NSNotification){
//        let info = aNotification.userInfo! as NSDictionary;
//
//        if(info.object(forKey: "Name") != nil && info.object(forKey: "Artist") != nil){
//            let name: String = info.value(forKey: "Name") as! String;
//            let artist: String = info.value(forKey: "Artist")as! String;
//
//            sysBar.title! = name + " - " + artist;
//            lastServiceUsed = Service.iTunes
//        }else if (info.object(forKey: "Name") != nil && info.object(forKey: "Artist") == nil) {
//            let name: String = info.value(forKey: "Name") as! String;
//            sysBar.title = "\(name)"
//        }
//
//        else{
//            sysBar.title! = "SongBar";
//        }
    }
    
    @objc func updateSpotifyFromNotification(aNotification: NSNotification){
//                let info = aNotification.userInfo! as NSDictionary;
//        if info["Name"] != nil && info["Artist"] != nil {
//            let name: String = info["Name"] as! String
//            let artist: String = info["Artist"] as! String
//            
//            sysBar.title = "\(name) - \(artist)"
//            
//            lastServiceUsed = Service.spotify
//        } else{
//            sysBar.title! = "SongBar";
//        }
    }
    
    @IBAction func playPause(sender: AnyObject) {
        print("Pause play")
    }
    
    @IBAction func findInStore(sender: AnyObject) {
//        var searchString: NSString = sysBar.title! as NSString
//        StoreSearch.sharedInstance.search(searchString)
    }
 

}

enum Service {
    case iTunes
    case spotify
}
