import TuneThatName
import Quick
import Nimble
import UIKit

class CreatePlaylistControllerSpec: QuickSpec {
    
    override func spec() {
        describe("CreatePlaylistController") {
            var navigationController: UINavigationController!
            var createPlaylistController: CreatePlaylistController!
            var mockPlaylistService: MockPlaylistService!
            var mockPreferencesService: MockPreferencesService!
            let expectedDefaultPlaylistPreferences = PlaylistPreferences(numberOfSongs: 10, filterContacts: false, songPreferences: SongPreferences(favorPopular: true, favorPositive: false, favorNegative: false))
            
            beforeEach() {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
                createPlaylistController = navigationController.childViewControllers.first as! CreatePlaylistController
                
                mockPlaylistService = MockPlaylistService()
                createPlaylistController.playlistService = mockPlaylistService
                mockPreferencesService = MockPreferencesService()
                createPlaylistController.preferencesService = mockPreferencesService

                UIApplication.sharedApplication().keyWindow!.rootViewController = navigationController
                NSRunLoop.mainRunLoop().runUntilDate(NSDate())
            }
            
            it("loads playlist preferences from preferences service") {
                expect(mockPreferencesService.mocker.getCallCountFor(MockPreferencesService.Method.retrievePlaylistPreferences)).toEventually(equal(1))
            }
            
            describe("number of songs slider") {
                it("has the correct initial value") {
                    expect(createPlaylistController.numberOfSongsSlider.value).to(beCloseTo(0.0909, within: 0.1837))
                }
            }
            
            describe("number of songs label") {
                it("has the correct initial text") {
                    expect(createPlaylistController.numberOfSongsLabel.text).to(
                        equal(String(expectedDefaultPlaylistPreferences.numberOfSongs)))
                }
            }
            
            describe("favor popular songs switch") {
                it("has the correct initial state") {
                    expect(createPlaylistController.favorPopularSwitch.on).to(
                        equal(expectedDefaultPlaylistPreferences.songPreferences.favorPopular))
                }
            }
            
            describe("select names button") {
                it("has the correct initial state") {
                    expect(createPlaylistController.selectNamesButton.titleLabel?.text).to(equal("Select Names"))
                    expect(createPlaylistController.selectNamesButton.enabled).to(beFalse())
                }
            }
            
            describe("filter contacts switch") {
                it("has the correct initial state") {
                    expect(createPlaylistController.filterContactsSwitch.on).to(
                        equal(expectedDefaultPlaylistPreferences.filterContacts))
                }
            }
            
            describe("number of songs slider value change") {
                context("when value changes") {
                    it("updates the number of songs label accordingly") {
                        createPlaylistController.numberOfSongsSlider.value = 1
                        createPlaylistController.numberOfSongsValueChanged(createPlaylistController.numberOfSongsSlider)
                        
                        expect(createPlaylistController.numberOfSongsLabel.text).to(equal("50"))
                    }
                }
            }
            
            describe("increment number of songs pressed") {
                beforeEach() {
                    createPlaylistController.incrementNumberOfSongsButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                }
                
                it("updates the number of songs label accordingly") {
                    expect(createPlaylistController.numberOfSongsLabel.text).to(equal("11"))
                }
                
                it("updates the number of songs slider accordingly") {
                    expect(createPlaylistController.numberOfSongsSlider.value).to(beCloseTo(0.1010, within: 0.2041))
                }
            }
            
            describe("decrement number of songs pressed") {
                beforeEach() {
                    createPlaylistController.decrementNumberOfSongsButton
                        .sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                }
                
                it("updates the number of songs label accordingly") {
                    expect(createPlaylistController.numberOfSongsLabel.text).to(equal("9"))
                }
                
                it("updates the number of songs slider accordingly") {
                    expect(createPlaylistController.numberOfSongsSlider.value).to(beCloseTo(0.0808, within: 0.1633))
                }
            }
            
            describe("favor popular songs switch state change") {
                context("when state changes") {
                    it("updates the favor popular flag") {
                        createPlaylistController.favorPopularSwitch.on = false
                        createPlaylistController.favorPopularStateChanged(createPlaylistController.favorPopularSwitch)
                        
                        createPlaylistController.createPlaylistButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect((mockPlaylistService.mocker.getNthCallTo(MockPlaylistService.Method.createPlaylistWithPreferences, n: 0)?.first as? PlaylistPreferences)?.songPreferences.favorPopular).toEventually(beFalse())
                    }
                }
            }
            
            describe("filter contacts state change") {
                context("to true") {
                    
                    beforeEach() {
                        createPlaylistController.filterContactsSwitch.on = true
                        createPlaylistController.filterContactsStateChanged(createPlaylistController.filterContactsSwitch)
                    }
                    
                    it("updates the 'select names' button appropriately") {
                        expect(createPlaylistController.selectNamesButton.enabled).toEventually(beTrue())
                    }
                    
                    it("updates the filter contacts flag") {
                        createPlaylistController.createPlaylistButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect((mockPlaylistService.mocker.getNthCallTo(MockPlaylistService.Method.createPlaylistWithPreferences, n: 0)?.first as? PlaylistPreferences)?.filterContacts).toEventually(beTrue())
                    }
                    
                    it("segues to the name selection view") {
                        expect(navigationController.topViewController)
                            .toEventually(beAnInstanceOf(NameSelectionTableController))
                    }
                }
                
                context("to false") {
                    beforeEach() {
                        createPlaylistController.filterContactsSwitch.on = false
                        createPlaylistController.filterContactsStateChanged(createPlaylistController.filterContactsSwitch)
                    }
                    
                    it("updates the 'select names' button appropriately") {
                        expect(createPlaylistController.selectNamesButton.enabled).toEventually(beFalse())
                    }
                    
                    it("updates the filter contacts flag") {
                        createPlaylistController.createPlaylistButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect((mockPlaylistService.mocker.getNthCallTo(MockPlaylistService.Method.createPlaylistWithPreferences, n: 0)?.first as? PlaylistPreferences)?.filterContacts).toEventually(beFalse())
                    }

                    it("does not segue") {
                        expect(navigationController.topViewController).toEventually(beAnInstanceOf(CreatePlaylistController))
                    }
                }
            }
            
            describe("press the 'select names' button") {
                beforeEach() {
                    createPlaylistController.selectNamesButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                }

                it("segues to the name selection view") {
                    expect(navigationController.topViewController).toEventually(beAnInstanceOf(NameSelectionTableController))
                }
                
                it("saves playlist preferences") {
                    expect(mockPreferencesService.mocker.getNthCallTo(
                        MockPreferencesService.Method.savePlaylistPreferences, n: 0)?.first as? PlaylistPreferences).toEventually(equal(expectedDefaultPlaylistPreferences))
                }
            }

            describe("press the create playlist button") {
                it("calls the playlist service with the correct number of songs") {
                    createPlaylistController.createPlaylistButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)

                    expect((mockPlaylistService.mocker.getNthCallTo(MockPlaylistService.Method.createPlaylistWithPreferences, n: 0)?.first as? PlaylistPreferences)?.numberOfSongs).toEventually(equal(expectedDefaultPlaylistPreferences.numberOfSongs))
                }
                
                context("when the playlist service calls back with an error") {
                    let expectedError = NSError(domain: "domain", code: 435, userInfo: [NSLocalizedDescriptionKey: "an error description"])
                    beforeEach() {
                        mockPlaylistService.mocker.prepareForCallTo(MockPlaylistService.Method.createPlaylistWithPreferences, returnValue: PlaylistService.PlaylistResult.Failure(expectedError))
                        
                        createPlaylistController.createPlaylistButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                    }
                    
                    it("does not segue to the playlist table view") {
                        expect(navigationController.topViewController).toEventuallyNot(beAnInstanceOf(SpotifyPlaylistTableController))
                    }

                    it("displays the error message in an alert") {
                        expect(createPlaylistController.presentedViewController).toEventuallyNot(beNil())
                        expect(createPlaylistController.presentedViewController).toEventually(beAnInstanceOf(UIAlertController))
                        let alertController = createPlaylistController.presentedViewController as! UIAlertController
                        expect(alertController.title).toEventually(equal("Unable to Create Your Playlist"))
                        expect(alertController.message).toEventually(equal((expectedError.userInfo![NSLocalizedDescriptionKey] as! String)))
                    }
                }
                
                context("when the playlist service calls back with a playlist") {
                    let expectedPlaylist = Playlist(name: "playlist")
                    beforeEach() {
                        mockPlaylistService.mocker.prepareForCallTo(MockPlaylistService.Method.createPlaylistWithPreferences, returnValue: PlaylistService.PlaylistResult.Success(expectedPlaylist))
                        
                        createPlaylistController.createPlaylistButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        NSRunLoop.mainRunLoop().runUntilDate(NSDate())
                    }
                    
                    it("segues to the playlist table view passing the playlist") {
                        expect(navigationController.topViewController).toEventually(
                            beAnInstanceOf(SpotifyPlaylistTableController))
                        let spotifyPlaylistTableController = navigationController.topViewController as? SpotifyPlaylistTableController
                        expect(spotifyPlaylistTableController?.playlist).to(equal(expectedPlaylist))
                    }
                    
                    it("saves playlist preferences") {
                        expect(mockPreferencesService.mocker.getNthCallTo(
                            MockPreferencesService.Method.savePlaylistPreferences, n: 0)?.first as? PlaylistPreferences).toEventually(equal(expectedDefaultPlaylistPreferences))
                    }
                }
            }
        }
    }
}

class MockPlaylistService: PlaylistService {
    
    let mocker = Mocker()
    
    struct Method {
        static let createPlaylistWithPreferences = "createPlaylistWithPreferences"
    }
    
    override func createPlaylistWithPreferences(playlistPreferences: PlaylistPreferences, callback: PlaylistService.PlaylistResult -> Void) {
        mocker.recordCall(Method.createPlaylistWithPreferences, parameters: playlistPreferences)
        let mockedResult = mocker.returnValueForCallTo(Method.createPlaylistWithPreferences)
        if let mockedResult = mockedResult as? PlaylistService.PlaylistResult {
            callback(mockedResult)
        } else {
            callback(.Success(Playlist(name: "unimportant mocked playlist")))
        }
    }
}