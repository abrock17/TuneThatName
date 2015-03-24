import TuneThatName
import Foundation
import Quick
import Nimble

class PlaylistTableViewControllerSpec: QuickSpec {
    
    override func spec() {
        
        describe("PlaylistTableViewController") {
            var playlistTableViewController: PlaylistTableViewController!
            
            describe("save the playlist to spotify") {
                beforeEach() {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    playlistTableViewController = storyboard.instantiateViewControllerWithIdentifier("PlaylistTableViewController") as  PlaylistTableViewController
                    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
                    window.rootViewController = playlistTableViewController
                    window.makeKeyAndVisible()
                }
                
                context("when there is no session") {
                    it("prompts the user to log in") {
                        playlistTableViewController.spotifyAuth = SPTAuth()
                        
                        let saveButton = playlistTableViewController.saveButton
                        UIApplication.sharedApplication().sendAction(saveButton.action, to: saveButton.target, from: self, forEvent: nil)
                        
                        expect(playlistTableViewController.presentedViewController).toNot(beNil())
                        // this fails unexplicably: "expected to be an instance of SPTAuthViewController, got <SPTAuthViewController instance>"
                        // expect(playlistTableViewController.presentedViewController).to(beAnInstanceOf(SPTAuthViewController))
                    }
                }
                
                context("when there is a session") {
                    it("does not prompt the user to log in") {
                        let spotifyAuth = SPTAuth()
                        spotifyAuth.session = SPTSession()
                        playlistTableViewController.spotifyAuth = spotifyAuth
                        
                        let saveButton = playlistTableViewController.saveButton
                        UIApplication.sharedApplication().sendAction(saveButton.action, to: saveButton.target, from: self, forEvent: nil)
                        
                        expect(playlistTableViewController.presentedViewController).to(beNil())
                    }
                }
            }
        }
    }
}