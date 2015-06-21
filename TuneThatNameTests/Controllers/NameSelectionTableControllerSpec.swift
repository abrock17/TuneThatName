import TuneThatName
import Quick
import Nimble

class NameSelectionTableControllerSpec: QuickSpec {
    
    override func spec() {
        describe("NameSelectionTableController") {
            var nameSelectionTableController: NameSelectionTableController!
            var mockContactService: MockContactService!
            var navigationController: UINavigationController!
            
            beforeEach() {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
                
                nameSelectionTableController = storyboard.instantiateViewControllerWithIdentifier("NameSelectionTableController") as!  NameSelectionTableController
                
                mockContactService = MockContactService()
                nameSelectionTableController.contactService = mockContactService
            }
            
            describe("table view") {
                var contactList = [
                    Contact(id: 1, firstName: "Johnny", lastName: "Knoxville", fullName: "Johnny Knoxville"),
                    Contact(id: 2, firstName: "Billy", lastName: "Joe Armstrong", fullName: "Billy Joe Armstrong"),
                    Contact(id: 3, firstName: "Frankie", lastName: "Furter", fullName: "Frankie Furter"),
                    Contact(id: 4, firstName: "Jimmy", lastName: "James", fullName: "Jimmy James and the Flames"),
                    Contact(id: 5, firstName: "$mitty", lastName: "Smith", fullName: "$mitty Smith")
                ]
                
                var expectedTitleHeaders: [String?] = Array(0...26).map({ _ in nil })
                expectedTitleHeaders[1] = "B"
                expectedTitleHeaders[5] = "F"
                expectedTitleHeaders[9] = "J"
                expectedTitleHeaders[26] = "#"
                
                var expectedSectionRowText: [[String]] = Array(0...26).map({ _ in [String]() })
                expectedSectionRowText[1] = [contactList[1].fullName]
                expectedSectionRowText[5] = [contactList[2].fullName]
                expectedSectionRowText[9] = [contactList[3].fullName, contactList[0].fullName]
                expectedSectionRowText[26] = [contactList[4].fullName]
                
                beforeEach() {
                    mockContactService.mocker.prepareForCallTo(MockContactService.Method.retrieveAllContacts, returnValue: ContactService.ContactListResult.Success(contactList))
                }
                
                context("contacts load successfully") {
                    beforeEach() {
                        self.loadView(navigationController: navigationController, viewController: nameSelectionTableController)
                    }
                    
                    it("has expected number of sections") {
                        expect(nameSelectionTableController.numberOfSectionsInTableView(nameSelectionTableController.tableView))
                            .to(equal(27))
                    }
                    
                    it("has expected index titles") {
                        expect(nameSelectionTableController.sectionIndexTitlesForTableView(nameSelectionTableController.tableView).count).to(equal(27))
                        expect(nameSelectionTableController.sectionIndexTitlesForTableView(nameSelectionTableController.tableView).first as? String).to(equal("A"))
                        expect(nameSelectionTableController.sectionIndexTitlesForTableView(nameSelectionTableController.tableView).last as? String).to(equal("#"))
                    }
                    
                    it("has expected section titles") {
                        for section in (0...26) {
                            if expectedTitleHeaders[section] != nil {
                                expect(nameSelectionTableController.tableView(nameSelectionTableController.tableView, titleForHeaderInSection: section)).to(equal(expectedTitleHeaders[section]))
                            } else {
                                expect(nameSelectionTableController.tableView(nameSelectionTableController.tableView, titleForHeaderInSection: section)).to(beNil())
                            }
                        }
                    }

                    it("has expected number of rows in each section") {
                        for section in (0...26) {
                            expect(nameSelectionTableController.tableView(nameSelectionTableController.tableView, numberOfRowsInSection: section)).to(equal(expectedSectionRowText[section].count))
                        }
                    }
                    
                    it("has expected contact names in each row") {
                        for section in (0...26) {
                            for (rowIndex, text) in enumerate(expectedSectionRowText[section]) {
                                let indexPath = NSIndexPath(forRow: rowIndex, inSection: section)
                                expect(nameSelectionTableController.tableView(nameSelectionTableController.tableView, cellForRowAtIndexPath: indexPath).textLabel?.text).to(equal(text))
                            }
                        }
                    }
                }
                
                context("when no contacts are filtered") {
                    let filteredContactList = [Contact]()
                    
                    beforeEach() {
                        mockContactService.mocker.prepareForCallTo(MockContactService.Method.retrieveFilteredContacts, returnValue: ContactService.ContactListResult.Success(filteredContactList))
                        self.loadView(navigationController: navigationController, viewController: nameSelectionTableController)
                    }
                    
                    it("adds a checkmark for all rows") {
                        for section in (0...26) {
                            for (rowIndex, text) in enumerate(expectedSectionRowText[section]) {
                                let indexPath = NSIndexPath(forRow: rowIndex, inSection: section)
                                let expectedAccessoryType: UITableViewCellAccessoryType = .Checkmark
                                expect(nameSelectionTableController.tableView(nameSelectionTableController.tableView, cellForRowAtIndexPath: indexPath).accessoryType.rawValue).to(equal(expectedAccessoryType.rawValue))
                            }
                        }
                    }
                    
                    describe("select a name") {
                        context("when the name has been selected") {
                            let indexPath = NSIndexPath(forRow: 0, inSection: 1)
                            
                            beforeEach() {
                                nameSelectionTableController.tableView(nameSelectionTableController.tableView, didSelectRowAtIndexPath: indexPath)
                            }
                            
                            it("has no accessory") {
                                expect(nameSelectionTableController.tableView(nameSelectionTableController.tableView, cellForRowAtIndexPath: indexPath).accessoryType).to(equal(UITableViewCellAccessoryType.None))
                            }
                        }
                    }
                    
                    context("when the name has not been selected") {
                        let indexPath = NSIndexPath(forRow: 0, inSection: 1)
                        
                        beforeEach() {
                            nameSelectionTableController.tableView(nameSelectionTableController.tableView, didSelectRowAtIndexPath: indexPath)
                            nameSelectionTableController.tableView(nameSelectionTableController.tableView, didSelectRowAtIndexPath: indexPath)
                        }
                        
                        it("has the checkmark accessory") {
                            expect(nameSelectionTableController.tableView(nameSelectionTableController.tableView, cellForRowAtIndexPath: indexPath).accessoryType).to(equal(UITableViewCellAccessoryType.Checkmark))
                        }
                    }
                }
                
                context("when contacts are filtered") {
                    let filteredContactList = [contactList[2]]
                    
                    beforeEach() {
                        mockContactService.mocker.prepareForCallTo(MockContactService.Method.retrieveFilteredContacts, returnValue: ContactService.ContactListResult.Success(filteredContactList))
                        self.loadView(navigationController: navigationController, viewController: nameSelectionTableController)
                    }
                    
                    it("adds a checkmark accessory only for the filtered contact row") {
                        for section in (0...26) {
                            for (rowIndex, text) in enumerate(expectedSectionRowText[section]) {
                                let indexPath = NSIndexPath(forRow: rowIndex, inSection: section)
                                let expectedAccessoryType: UITableViewCellAccessoryType = indexPath.section == 5 && indexPath.row == 0 ? .Checkmark : .None
                                expect(nameSelectionTableController.tableView(nameSelectionTableController.tableView, cellForRowAtIndexPath: indexPath).accessoryType.rawValue).to(equal(expectedAccessoryType.rawValue))
                            }
                        }
                    }
                    
                    describe("unwind to create playlist") {
                        it("saves filtered contacts") {
                            nameSelectionTableController.performSegueWithIdentifier("UnwindToCreatePlaylistFromNameSelectionSegue", sender: nil)
                            NSRunLoop.mainRunLoop().runUntilDate(NSDate())
                            
                            expect(mockContactService.mocker.getNthCallTo(MockContactService.Method.saveFilteredContacts, n: 0)?.first as? [Contact]).to(equal(filteredContactList))
                        }
                    }
                }
            }
        }
    }
    
    func loadView(#navigationController: UINavigationController, viewController: UIViewController) {
        navigationController.pushViewController(viewController, animated: false)
        UIApplication.sharedApplication().keyWindow!.rootViewController = navigationController
        NSRunLoop.mainRunLoop().runUntilDate(NSDate())
    }
}