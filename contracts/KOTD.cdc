import NonFungibleToken from 0x631e88ae7f1d7c20

pub contract KOTD: NonFungibleToken {

    // -----------------------------------------------------------------------
    // Contract Events
    // -----------------------------------------------------------------------
    pub event ContractInitialized()
    
    // Emitted when a new Moment struct is created
    pub event MomentCreated(id: UInt32, metadata: {String:String})
    // Emitted when a new series has been triggered by an admin
    pub event NewSeriesStarted(newCurrentSeries: UInt32)

    // Events for Set-Related actions
    //
    // Emitted when a new Set is created
    pub event SetCreated(setID: UInt32, series: UInt32)
    // Emitted when a new Moment is added to a Set
    pub event MomentAddedToSet(setID: UInt32, momentID: UInt32)
    // Emitted when a Moment is retired from a Set and cannot be used to mint
    pub event MomentRetiredFromSet(setID: UInt32, momentID: UInt32, numMoments: UInt32)
    // Emitted when a Set is locked, meaning Moments cannot be added
    pub event SetLocked(setID: UInt32)
    // Emitted when a Collectible is minted from a Set
    pub event CollectibleMinted(collectibleID: UInt64, momentID: UInt32, setID: UInt32, serialNumber: UInt32)

    // Events for Collection-related actions
    //
    // Emitted when a moment is withdrawn from a Collection
    pub event Withdraw(id: UInt64, from: Address?)
    // Emitted when a moment is deposited into a Collection
    pub event Deposit(id: UInt64, to: Address?)

    // Emitted when a Collectible is destroyed
    pub event CollectibleDestroyed(id: UInt64)

    // -----------------------------------------------------------------------
    // Contract-level fields
    // These contain actual values that are stored in the smart contract.
    // -----------------------------------------------------------------------
    
    // Series that this Set belongs to.
    // Series is a concept that indicates a group of Sets through time.
    // Many Sets can exist at a time, but only one series.
    pub var currentSeries: UInt32

    // Variable size dictionary of Moment structs
    access(self) var momentDatas: {UInt32: Moment}

    // Variable size dictionary of SetData structs
    access(self) var setDatas: {UInt32: SetData}

    // Variable size dictionary of Set resources
    access(self) var sets: @{UInt32: Set}

    // The ID that is used to create Moments. 
    // Every time a Moment is created, momentID is assigned 
    // to the new Moment's ID and then is incremented by 1.
    pub var nextMomentID: UInt32

    // The ID that is used to create Sets. Every time a Set is created
    // setID is assigned to the new set's ID and then is incremented by 1.
    pub var nextSetID: UInt32
    
    // totalSupply
    // The total number of KOTD that have been minted
    //
    pub var totalSupply: UInt64

    // -----------------------------------------------------------------------
    // Contract-level Composite Type definitions
    // -----------------------------------------------------------------------
    // These are just *definitions* for Types that this contract
    // and other accounts can use. These definitions do not contain
    // actual stored values, but an instance (or object) of one of these Types
    // can be created by this contract that contains stored values.
    // -----------------------------------------------------------------------
    
    // Moment is a Struct that holds metadata associated 
    // with a specific NBA moment, like the legendary moment when 
    // Ray Allen hit the 3 to tie the Heat and Spurs in the 2013 finals game 6
    // or when Lance Stephenson blew in the ear of Lebron James.
    //
    // Collectible NFTs will all reference a single moment as the owner of
    // its metadata. The moments are publicly accessible, so anyone can
    // read the metadata associated with a specific moment ID
    //
    pub struct Moment {

        // The unique ID for the Moment
        pub let momentID: UInt32

        // Stores all the metadata about the moment as a string mapping
        // This is not the long term way NFT metadata will be stored. It's a temporary
        // construct while we figure out a better way to do metadata.
        //
        pub let metadata: {String: String}

        init(metadata: {String: String}) {
            pre {
                metadata.length != 0: "New Moment metadata cannot be empty"
            }
            self.momentID = KOTD.nextMomentID
            self.metadata = metadata

            // Increment the ID so that it isn't used again
            KOTD.nextMomentID = KOTD.nextMomentID + UInt32(1)

            emit MomentCreated(id: self.momentID, metadata: metadata)
        }
    }

    // A Set is a grouping of Moments that have occured in the real world
    // that make up a related group of collectibles, like sets of baseball
    // or Magic cards. A Moment can exist in multiple different sets.
    // 
    // SetData is a struct that is stored in a field of the contract.
    // Anyone can query the constant information
    // about a set by calling various getters located 
    // at the end of the contract. Only the admin has the ability 
    // to modify any data in the private Set resource.
    //
    pub struct SetData {

        // Unique ID for the Set
        pub let setID: UInt32

        // Name of the Set
        // ex. "Times when the Toronto Raptors choked in the playoffs"
        pub let name: String

        // Series that this Set belongs to.
        // Series is a concept that indicates a group of Sets through time.
        // Many Sets can exist at a time, but only one series.
        pub let series: UInt32

        init(name: String) {
            pre {
                name.length > 0: "New Set name cannot be empty"
            }
            self.setID = KOTD.nextSetID
            self.name = name
            self.series = KOTD.currentSeries

            // Increment the setID so that it isn't used again
            KOTD.nextSetID = KOTD.nextSetID + UInt32(1)

            emit SetCreated(setID: self.setID, series: self.series)
        }
    }

    // Set is a resource type that contains the functions to add and remove
    // Moments from a set and mint Collectibles.
    //
    // It is stored in a private field in the contract so that
    // the admin resource can call its methods.
    //
    // The admin can add Moments to a Set so that the set can mint Collectibles
    // that reference that playdata.
    // The Collectibles that are minted by a Set will be listed as belonging to
    // the Set that minted it, as well as the Moment it references.
    // 
    // Admin can also retire Moments from the Set, meaning that the retired
    // Moment can no longer have Collectibles minted from it.
    //
    // If the admin locks the Set, no more Moments can be added to it, but 
    // Collectibles can still be minted.
    //
    // If retireAll() and lock() are called back-to-back, 
    // the Set is closed off forever and nothing more can be done with it.
    pub resource Set {

        // Unique ID for the set
        pub let setID: UInt32

        // Array of moments that are a part of this set.
        // When a moment is added to the set, its ID gets appended here.
        // The ID does not get removed from this array when a Moment is retired.
        pub var moments: [UInt32]

        // Map of Moment IDs that Indicates if a Moment in this Set can be minted.
        // When a Moment is added to a Set, it is mapped to false (not retired).
        // When a Moment is retired, this is set to true and cannot be changed.
        pub var retired: {UInt32: Bool}

        // Indicates if the Set is currently locked.
        // When a Set is created, it is unlocked 
        // and Moments are allowed to be added to it.
        // When a set is locked, Moments cannot be added.
        // A Set can never be changed from locked to unlocked,
        // the decision to lock a Set it is final.
        // If a Set is locked, Moments cannot be added, but
        // Collectibles can still be minted from Moments
        // that exist in the Set.
        pub var locked: Bool

        // Mapping of Moment IDs that indicates the number of Collectibles 
        // that have been minted for specific Moments in this Set.
        // When a Collectible is minted, this value is stored in the Collectible to
        // show its place in the Set, eg. 13 of 60.
        pub var numberMintedPerMoment: {UInt32: UInt32}

        init(name: String) {
            self.setID = KOTD.nextSetID
            self.moments = []
            self.retired = {}
            self.locked = false
            self.numberMintedPerMoment = {}

            // Create a new SetData for this Set and store it in contract storage
            KOTD.setDatas[self.setID] = SetData(name: name)
        }

        // addMoment adds a moment to the set
        //
        // Parameters: momentID: The ID of the Moment that is being added
        //
        // Pre-Conditions:
        // The Moment needs to be an existing moment
        // The Set needs to be not locked
        // The Moment can't have already been added to the Set
        //
        pub fun addMoment(momentID: UInt32) {
            pre {
                KOTD.momentDatas[momentID] != nil: "Cannot add the Moment to Set: Moment doesn't exist."
                !self.locked: "Cannot add the moment to the Set after the set has been locked."
                self.numberMintedPerMoment[momentID] == nil: "The moment has already beed added to the set."
            }

            // Add the Moment to the array of Moments
            self.moments.append(momentID)

            // Open the Moment up for minting
            self.retired[momentID] = false

            // Initialize the Collectible count to zero
            self.numberMintedPerMoment[momentID] = 0

            emit MomentAddedToSet(setID: self.setID, momentID: momentID)
        }

        // addMoments adds multiple Moments to the Set
        //
        // Parameters: momentIDs: The IDs of the Moments that are being added
        //                      as an array
        //
        pub fun addMoments(momentIDs: [UInt32]) {
            for moment in momentIDs {
                self.addMoment(momentID: moment)
            }
        }

        // retireMoment retires a Moment from the Set so that it can't mint new Collectibles
        //
        // Parameters: momentID: The ID of the Moment that is being retired
        //
        // Pre-Conditions:
        // The Moment is part of the Set and not retired (available for minting).
        // 
        pub fun retireMoment(momentID: UInt32) {
            pre {
                self.retired[momentID] != nil: "Cannot retire the Moment: Moment doesn't exist in this set!"
            }

            if !self.retired[momentID]! {
                self.retired[momentID] = true

                emit MomentRetiredFromSet(setID: self.setID, momentID: momentID, numMoments: self.numberMintedPerMoment[momentID]!)
            }
        }

        // retireAll retires all the moments in the Set
        // Afterwards, none of the retired Moments will be able to mint new Collectibles
        //
        pub fun retireAll() {
            for moment in self.moments {
                self.retireMoment(momentID: moment)
            }
        }

        // lock() locks the Set so that no more Moments can be added to it
        //
        // Pre-Conditions:
        // The Set should not be locked
        pub fun lock() {
            if !self.locked {
                self.locked = true
                emit SetLocked(setID: self.setID)
            }
        }

        // mintCollectible mints a new Collectible and returns the newly minted Collectible
        // 
        // Parameters: momentID: The ID of the Moment that the Collectible references
        //
        // Pre-Conditions:
        // The Moment must exist in the Set and be allowed to mint new Collectibles
        //
        // Returns: The NFT that was minted
        // 
        pub fun mintCollectible(momentID: UInt32): @NFT {
            pre {
                self.retired[momentID] != nil: "Cannot mint the moment: This moment doesn't exist."
                !self.retired[momentID]!: "Cannot mint the moment from this moment: This moment has been retired."
            }

            // Gets the number of Collectibles that have been minted for this Moment
            // to use as this Collectible's serial number
            let numInPlay = self.numberMintedPerMoment[momentID]!

            // Mint the new moment
            let newCollectible: @NFT <- create NFT(serialNumber: numInPlay + UInt32(1),
                                              momentID: momentID,
                                              setID: self.setID)

            // Increment the count of Collectibles minted for this Moment
            self.numberMintedPerMoment[momentID] = numInPlay + UInt32(1)

            return <-newCollectible
        }

        // batchMintCollectible mints an arbitrary quantity of Collectibles 
        // and returns them as a Collection
        //
        // Parameters: momentID: the ID of the Moment that the Collectibles are minted for
        //             quantity: The quantity of Collectibles to be minted
        //
        // Returns: Collection object that contains all the Collectibles that were minted
        //
        pub fun batchMintCollectible(momentID: UInt32, quantity: UInt64): @Collection {
            let newCollection <- create Collection()

            var i: UInt64 = 0
            while i < quantity {
                newCollection.deposit(token: <-self.mintCollectible(momentID: momentID))
                i = i + UInt64(1)
            }

            return <-newCollection
        }
    }

    pub struct CollectibleData {

        // The ID of the Set that the Collectible comes from
        pub let setID: UInt32

        // The ID of the Moment that the Collectible references
        pub let momentID: UInt32

        // The place in the edition that this Collectible was minted
        // Otherwise know as the serial number
        pub let serialNumber: UInt32

        init(setID: UInt32, momentID: UInt32, serialNumber: UInt32) {
            self.setID = setID
            self.momentID = momentID
            self.serialNumber = serialNumber
        }

    }


    // Admin is a special authorization resource that 
    // allows the owner to perform important functions to modify the 
    // various aspects of the Moments, Sets, and Collectibles
    
    pub resource Admin {

        // createMoment creates a new Moment struct 
        // and stores it in the Moments dictionary in the KOTD smart contract
        //
        // Parameters: metadata: A dictionary mapping metadata titles to their data
        //                       example: {"Player Name": "Kevin Durant", "Height": "7 feet"}
        //                               (because we all know Kevin Durant is not 6'9")
        //
        // Returns: the ID of the new Moment object
        //
        pub fun createMoment(metadata: {String: String}): UInt32 {
            // Create the new Moment
            var newMoment = Moment(metadata: metadata)
            let newID = newMoment.momentID

            // Store it in the contract storage
            KOTD.momentDatas[newID] = newMoment

            return newID
        }

        // createSet creates a new Set resource and stores it
        // in the sets mapping in the KOTD contract
        //
        // Parameters: name: The name of the Set
        //
        pub fun createSet(name: String) {
            // Create the new Set
            var newSet <- create Set(name: name)

            // Store it in the sets mapping field
            KOTD.sets[newSet.setID] <-! newSet
        }

        // borrowSet returns a reference to a set in the KOTD
        // contract so that the admin can call methods on it
        //
        // Parameters: setID: The ID of the Set that you want to
        // get a reference to
        //
        // Returns: A reference to the Set with all of the fields
        // and methods exposed
        //
        pub fun borrowSet(setID: UInt32): &Set {
            pre {
                KOTD.sets[setID] != nil: "Cannot borrow Set: The Set doesn't exist"
            }
            
            // Get a reference to the Set and return it
            // use `&` to indicate the reference to the object and type
            return &KOTD.sets[setID] as &Set
        }

        // startNewSeries ends the current series by incrementing
        // the series number, meaning that Collectibles minted after this
        // will use the new series number
        //
        // Returns: The new series number
        //
        pub fun startNewSeries(): UInt32 {
            // End the current series and start a new one
            // by incrementing the KOTD series number
            KOTD.currentSeries = KOTD.currentSeries + UInt32(1)

            emit NewSeriesStarted(newCurrentSeries: KOTD.currentSeries)

            return KOTD.currentSeries
        }

        // createNewAdmin creates a new Admin resource
        //
        pub fun createNewAdmin(): @Admin {
            return <-create Admin()
        }
    }

    // The resource that represents the Collectible NFTs
    //
    pub resource NFT: NonFungibleToken.INFT {

        // Global unique moment ID
        pub let id: UInt64
        
        // Struct of Collectible metadata
        pub let data: CollectibleData

        init(serialNumber: UInt32, momentID: UInt32, setID: UInt32) {
            // Increment the global Collectible IDs
            KOTD.totalSupply = KOTD.totalSupply + UInt64(1)

            self.id = KOTD.totalSupply

            // Set the metadata struct
            self.data = CollectibleData(setID: setID, momentID: momentID, serialNumber: serialNumber)

            emit CollectibleMinted(collectibleID: self.id, momentID: momentID, setID: self.data.setID, serialNumber: self.data.serialNumber)
        }

        // If the Collectible is destroyed, emit an event to indicate 
        // to outside ovbservers that it has been destroyed
        destroy() {
            emit CollectibleDestroyed(id: self.id)
        }
    }


    // This is the interface that users can cast their Collectible Collection as
    // to allow others to deposit Collectibles into their Collection. It also allows for reading
    // the IDs of Collectibles in the Collection.
    pub resource interface CollectibleCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun batchDeposit(tokens: @NonFungibleToken.Collection)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowCollectible(id: UInt64): &KOTD.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id): 
                    "Cannot borrow Collectible reference: The ID of the returned reference is incorrect"
            }
        }
    }

       // Collection is a resource that every user who owns NFTs 
    // will store in their account to manage their NFTS
    //
    pub resource Collection: CollectibleCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic { 
        // Dictionary of Collectible conforming tokens
        // NFT is a resource type with a UInt64 ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init() {
            self.ownedNFTs <- {}
        }

        // withdraw removes an Collectible from the Collection and moves it to the caller
        //
        // Parameters: withdrawID: The ID of the NFT 
        // that is to be removed from the Collection
        //
        // returns: @NonFungibleToken.NFT the token that was withdrawn
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {

            // Remove the nft from the Collection
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("Cannot withdraw: Collectible does not exist in the collection")

            emit Withdraw(id: token.id, from: self.owner?.address)
            
            // Return the withdrawn token
            return <-token
        }

        // batchWithdraw withdraws multiple tokens and returns them as a Collection
        //
        // Parameters: ids: An array of IDs to withdraw
        //
        // Returns: @NonFungibleToken.Collection: A collection that contains
        //                                        the withdrawn moments
        //
        pub fun batchWithdraw(ids: [UInt64]): @NonFungibleToken.Collection {
            // Create a new empty Collection
            var batchCollection <- create Collection()
            
            // Iterate through the ids and withdraw them from the Collection
            for id in ids {
                batchCollection.deposit(token: <-self.withdraw(withdrawID: id))
            }
            
            // Return the withdrawn tokens
            return <-batchCollection
        }

        // deposit takes a Collectible and adds it to the Collections dictionary
        //
        // Paramters: token: the NFT to be deposited in the collection
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            
            // Cast the deposited token as a KOTD NFT to make sure
            // it is the correct type
            let token <- token as! @KOTD.NFT

            // Get the token's ID
            let id = token.id

            // Add the new token to the dictionary
            let oldToken <- self.ownedNFTs[id] <- token

            // Only emit a deposit event if the Collection 
            // is in an account's storage
            if self.owner?.address != nil {
                emit Deposit(id: id, to: self.owner?.address)
            }

            // Destroy the empty old token that was "removed"
            destroy oldToken
        }

        // batchDeposit takes a Collection object as an argument
        // and deposits each contained NFT into this Collection
        pub fun batchDeposit(tokens: @NonFungibleToken.Collection) {

            // Get an array of the IDs to be deposited
            let keys = tokens.getIDs()

            // Iterate through the keys in the collection and deposit each one
            for key in keys {
                self.deposit(token: <-tokens.withdraw(withdrawID: key))
            }

            // Destroy the empty Collection
            destroy tokens
        }

        // getIDs returns an array of the IDs that are in the Collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT Returns a borrowed reference to a Collectible in the Collection
        // so that the caller can read its ID
        //
        // Parameters: id: The ID of the NFT to get the reference for
        //
        // Returns: A reference to the NFT
        //
        // Note: This only allows the caller to read the ID of the NFT,
        // not any KOTD specific data. Please use borrowCollectible to 
        // read Collectible data.
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowCollectible returns a borrowed reference to a Collectible
        // so that the caller can read data and call methods from it.
        // They can use this to read its setID, momentID, serialNumber,
        // or any of the setData or Moment data associated with it by
        // getting the setID or momentID and reading those fields from
        // the smart contract.
        //
        // Parameters: id: The ID of the NFT to get the reference for
        //
        // Returns: A reference to the NFT
        pub fun borrowCollectible(id: UInt64): &KOTD.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &KOTD.NFT
            } else {
                return nil
            }
        }

        // If a transaction destroys the Collection object,
        // All the NFTs contained within are also destroyed!
        // Much like when Damian Lillard destroys the hopes and
        // dreams of the entire city of Houston.
        //
        destroy() {
            destroy self.ownedNFTs
        }
    }

    // -----------------------------------------------------------------------
    // Contract-level function definitions
    // -----------------------------------------------------------------------
    
        // createEmptyCollection creates a new, empty Collection object so that
    // a user can store it in their account storage.
    // Once they have a Collection in their storage, they are able to receive
    // Collectibles in transactions.
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <-create KOTD.Collection()
    }

    // getAllMoments returns all the moments in KOTD
    //
    // Returns: An array of all the moments that have been created
    pub fun getAllMoments(): [KOTD.Moment] {
        return KOTD.momentDatas.values
    }

    // getMomentMetaData returns all the metadata associated with a specific Moment
    // 
    // Parameters: momentID: The id of the Moment that is being searched
    //
    // Returns: The metadata as a String to String mapping optional
    pub fun getMomentMetaData(momentID: UInt32): {String: String}? {
        return self.momentDatas[momentID]?.metadata
    }

    // getMomentMetaDataByField returns the metadata associated with a 
    //                        specific field of the metadata
    //                        Ex: field: "Team" will return something
    //                        like "Memphis Grizzlies"
    // 
    // Parameters: momentID: The id of the Moment that is being searched
    //             field: The field to search for
    //
    // Returns: The metadata field as a String Optional
    pub fun getMomentMetaDataByField(momentID: UInt32, field: String): String? {
        // Don't force a revert if the momentID or field is invalid
        if let moment = KOTD.momentDatas[momentID] {
            return moment.metadata[field]
        } else {
            return nil
        }
    }

    // getSetName returns the name that the specified Set
    //            is associated with.
    // 
    // Parameters: setID: The id of the Set that is being searched
    //
    // Returns: The name of the Set
    pub fun getSetName(setID: UInt32): String? {
        // Don't force a revert if the setID is invalid
        return KOTD.setDatas[setID]?.name
    }

    // getSetSeries returns the series that the specified Set
    //              is associated with.
    // 
    // Parameters: setID: The id of the Set that is being searched
    //
    // Returns: The series that the Set belongs to
    pub fun getSetSeries(setID: UInt32): UInt32? {
        // Don't force a revert if the setID is invalid
        return KOTD.setDatas[setID]?.series
    }

    // getSetIDsByName returns the IDs that the specified Set name
    //                 is associated with.
    // 
    // Parameters: setName: The name of the Set that is being searched
    //
    // Returns: An array of the IDs of the Set if it exists, or nil if doesn't
    pub fun getSetIDsByName(setName: String): [UInt32]? {
        var setIDs: [UInt32] = []

        // Iterate through all the setDatas and search for the name
        for setData in KOTD.setDatas.values {
            if setName == setData.name {
                // If the name is found, return the ID
                setIDs.append(setData.setID)
            }
        }

        // If the name isn't found, return nil
        // Don't force a revert if the setName is invalid
        if setIDs.length == 0 {
            return nil
        } else {
            return setIDs
        }
    }

    // getMomentsInSet returns the list of Moment IDs that are in the Set
    // 
    // Parameters: setID: The id of the Set that is being searched
    //
    // Returns: An array of Moment IDs
    pub fun getMomentsInSet(setID: UInt32): [UInt32]? {
        // Don't force a revert if the setID is invalid
        return KOTD.sets[setID]?.moments
    }

    // isEditionRetired returns a boolean that indicates if a Set/Moment combo
    //                  (otherwise known as an edition) is retired.
    //                  If an edition is retired, it still remains in the Set,
    //                  but Collectibles can no longer be minted from it.
    // 
    // Parameters: setID: The id of the Set that is being searched
    //             momentID: The id of the Moment that is being searched
    //
    // Returns: Boolean indicating if the edition is retired or not
    pub fun isEditionRetired(setID: UInt32, momentID: UInt32): Bool? {
        // Don't force a revert if the set or moment ID is invalid
        // Remove the set from the dictionary to get its field
        if let setToRead <- KOTD.sets.remove(key: setID) {

            // See if the Moment is retired from this Set
            let retired = setToRead.retired[momentID]

            // Put the Set back in the contract storage
            KOTD.sets[setID] <-! setToRead

            // Return the retired status
            return retired
        } else {

            // If the Set wasn't found, return nil
            return nil
        }
    }

    // isSetLocked returns a boolean that indicates if a Set
    //             is locked. If it's locked, 
    //             new Moments can no longer be added to it,
    //             but Collectibles can still be minted from Moments the set contains.
    // 
    // Parameters: setID: The id of the Set that is being searched
    //
    // Returns: Boolean indicating if the Set is locked or not
    pub fun isSetLocked(setID: UInt32): Bool? {
        // Don't force a revert if the setID is invalid
        return KOTD.sets[setID]?.locked
    }

    // getNumMomentsInEdition return the number of Collectibles that have been 
    //                        minted from a certain edition.
    //
    // Parameters: setID: The id of the Set that is being searched
    //             momentID: The id of the Moment that is being searched
    //
    // Returns: The total number of Collectibles 
    //          that have been minted from an edition
    pub fun getNumMomentsInEdition(setID: UInt32, momentID: UInt32): UInt32? {
        // Don't force a revert if the Set or moment ID is invalid
        // Remove the Set from the dictionary to get its field
        if let setToRead <- KOTD.sets.remove(key: setID) {

            // Read the numMintedPerPlay
            let amount = setToRead.numberMintedPerMoment[momentID]

            // Put the Set back into the Sets dictionary
            KOTD.sets[setID] <-! setToRead

            return amount
        } else {
            // If the set wasn't found return nil
            return nil
        }
    }

    // -----------------------------------------------------------------------
    // Contract initialization function
    // -----------------------------------------------------------------------
    
    init() {
        // Initialize contract fields
        self.currentSeries = 0
        self.momentDatas = {}
        self.setDatas = {}
        self.sets <- {}
        self.nextMomentID = 1
        self.nextSetID = 1
        self.totalSupply = 0

        // Put a new Collection in storage @TODO: change to "CollectibleCollection"
        self.account.save<@Collection>(<- create Collection(), to: /storage/MomentCollection001)

        // Create a public capability for the Collection
        self.account.link<&{CollectibleCollectionPublic}>(/public/MomentCollection, target: /storage/MomentCollection001)

        // Put the Minter in storage
        self.account.save<@Admin>(<- create Admin(), to: /storage/KOTDAdmin001)

        emit ContractInitialized()
    }
}