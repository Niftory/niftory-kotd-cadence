import NonFungibleToken from "./NonFungibleToken.cdc"

pub contract KOTD: NonFungibleToken {

    // -----------------------------------------------------------------------
    // Public Paths
    // -----------------------------------------------------------------------

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let AdminStoragePath: StoragePath
    
    // -----------------------------------------------------------------------
    // Contract Events
    // -----------------------------------------------------------------------
    pub event ContractInitialized()
    
    // Emitted when a new CollectibleItem struct is created
    pub event CollectibleItemCreated(id: UInt32, metadata: {String:String})
    // Emitted when a new series has been triggered by an admin
    pub event NewSeriesStarted(newCurrentSeries: UInt32)

    // Events for Set-Related actions
    //
    // Emitted when a new Set is created
    pub event SetCreated(setID: UInt32, series: UInt32)
    // Emitted when a new CollectibleItem is added to a Set
    pub event CollectibleItemAddedToSet(setID: UInt32, collectibleItemID: UInt32)
    // Emitted when a CollectibleItem is retired from a Set and cannot be used to mint
    pub event CollectibleItemRetiredFromSet(setID: UInt32, collectibleItemID: UInt32, numCollectibleItems: UInt32)
    // Emitted when a Set is locked, meaning CollectibleItems cannot be added
    pub event SetLocked(setID: UInt32)
    // Emitted when a Collectible is minted from a Set
    pub event CollectibleMinted(collectibleID: UInt64, collectibleItemID: UInt32, setID: UInt32, serialNumber: UInt32)

    // Events for Collection-related actions
    //
    // Emitted when a collectibleItem is withdrawn from a Collection
    pub event Withdraw(id: UInt64, from: Address?)
    // Emitted when a collectibleItem is deposited into a Collection
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
    
    //pointer to the current active Series
    pub var currentSeriesID: UInt32

    //Variable size dictionary of Series structs.
    access(self) var seriesDatas: {UInt32: Series}

    // Variable size dictionary of CollectibleItem structs
    access(self) var collectibleItemDatas: {UInt32: CollectibleItem}

    // Variable size dictionary of Set resources
    access(self) var sets: @{UInt32: Set}

    // The ID that is used to create CollectibleItems. 
    // Every time a CollectibleItem is created, collectibleItemID is assigned 
    // to the new CollectibleItem's ID and then is incremented by 1.
    pub var nextCollectibleItemID: UInt32

    // The ID that is used to create Sets. Every time a Set is created
    // setID is assigned to the new set's ID and then is incremented by 1.
    pub var nextSetID: UInt32
    
    // totalSupply
    // The total number of KOTD Collectibles that have been minted
    pub var totalSupply: UInt64

    // -----------------------------------------------------------------------
    // Contract-level Composite Type definitions
    // -----------------------------------------------------------------------
    // These are just *definitions* for Types that this contract
    // and other accounts can use. These definitions do not contain
    // actual stored values, but an instance (or object) of one of these Types
    // can be created by this contract that contains stored values.
    // -----------------------------------------------------------------------
    
    pub struct Series {
        pub let seriesID: UInt32

        pub let name: String?

        pub let seriesIdentityURL: String?

         init(seriesID: UInt32, name: String?, seriesIdentityURL: String?) {
            self.seriesID = seriesID
            self.name = name
            self.seriesIdentityURL = seriesIdentityURL
        }
    }

    pub struct CurrSeriesData {
        pub let seriesID: UInt32

        pub let name: String?

        pub let seriesIdentityURL: String?

         init() {
            var referencedSeries = &KOTD.seriesDatas[KOTD.currentSeriesID] as &Series
            self.seriesID = referencedSeries.seriesID
            self.name = referencedSeries.name
            self.seriesIdentityURL = referencedSeries.seriesIdentityURL
        }
    }
    
    // CollectibleItem is a Struct that holds metadata associated 
    // with a moment, entity, or other representative collectible.
    // Collectible NFTs will all reference a single CollectibleItem as the owner of
    // its metadata. CllectibleItems are publicly accessible, so anyone can
    // read the metadata associated with a specific CollectibleItem ID
    
    pub struct CollectibleItem {

        // The unique ID for the CollectibleItem
        pub let collectibleItemID: UInt32

        // Stores all the metadata about the CollectibleItem as a string mapping
        
        pub let metadata: {String: String}

        init(metadata: {String: String}) {
            pre {
                metadata.length != 0: "New CollectibleItem metadata cannot be empty"
            }
            self.collectibleItemID = KOTD.nextCollectibleItemID
            self.metadata = metadata

            // Increment the ID so that it isn't used again
            KOTD.nextCollectibleItemID = KOTD.nextCollectibleItemID + UInt32(1)

            emit CollectibleItemCreated(id: self.collectibleItemID, metadata: metadata)
        }
    }

    // A Set is a grouping of CollectibleItems that make up a related group of collectibles, 
    // like sets of baseball or Magic cards. A CollectibleItem can exist in multiple different sets.
    // SetData is a struct that is stored in a field of the contract.
    // Anyone can query the constant information
    // about a set by calling various getters located 
    // at the end of the contract. Only the admin has the ability 
    // to modify any data in the private Set resource.
    
    pub struct SetData {

        pub let setID: UInt32

        pub let name: String

        pub let setIdentityURL: String?

        pub let description: String?

        pub let series: Series

        pub var collectibleItems: [UInt32]

        pub var retired: {UInt32: Bool}

        pub var locked: Bool

        pub var numberMintedPerCollectibleItem: {UInt32: UInt32}

        init(setID: UInt32) {
            var referencedSet = &KOTD.sets[setID] as &Set

            self.setID = referencedSet.setID
            self.name = referencedSet.name
            self.setIdentityURL = referencedSet.setIdentityURL
            self.description = referencedSet.description
            self.series = referencedSet.series
            self.collectibleItems = referencedSet.collectibleItems
            self.retired = referencedSet.retired
            self.locked = referencedSet.locked
            self.numberMintedPerCollectibleItem = referencedSet.numberMintedPerCollectibleItem
        }
    }

    // Set is a resource type that contains the functions to add and remove
    // CollectibleItems from a set and mint Collectibles.
    //
    // It is stored in a private field in the contract so that
    // the admin resource can call its methods.
    //
    // The admin can add CollectibleItems to a Set so that the set can mint Collectibles
    // that reference that playdata.
    // The Collectibles that are minted by a Set will be listed as belonging to
    // the Set that minted it, as well as the CollectibleItem it references.
    // 
    // Admin can also retire CollectibleItems from the Set, meaning that the retired
    // CollectibleItem can no longer have Collectibles minted from it.
    //
    // If the admin locks the Set, no more CollectibleItems can be added to it, but 
    // Collectibles can still be minted.
    //
    // If retireAll() and lock() are called back-to-back, 
    // the Set is closed off forever and nothing more can be done with it.
    pub resource Set {

        // Unique ID for the set
        pub let setID: UInt32

        // Name of the Set
        pub let name: String

        // Series that this Set belongs to.
        // Series is a concept that indicates a group of Sets through time.
        // Many Sets can exist at a time, but only one Series.
        pub let series: Series

        // Optional string to hold URL for an identity visual associated with a Set.
        pub let setIdentityURL: String?

        pub let description: String?

        // Array of collectibleItems that are a part of this set.
        // When a collectibleItem is added to the set, its ID gets appended here.
        // The ID does not get removed from this array when a CollectibleItem is retired.
        pub var collectibleItems: [UInt32]

        // Map of CollectibleItem IDs that Indicates if a CollectibleItem in this Set can be minted.
        // When a CollectibleItem is added to a Set, it is mapped to false (not retired).
        // When a CollectibleItem is retired, this is set to true and cannot be changed.
        pub var retired: {UInt32: Bool}

        // Indicates if the Set is currently locked.
        // When a Set is created, it is unlocked 
        // and CollectibleItems are allowed to be added to it.
        // When a set is locked, CollectibleItems cannot be added.
        // A Set can never be changed from locked to unlocked,
        // the decision to lock a Set it is final.
        // If a Set is locked, CollectibleItems cannot be added, but
        // Collectibles can still be minted from CollectibleItems
        // that exist in the Set.
        pub var locked: Bool

        // Mapping of CollectibleItem IDs that indicates the number of Collectibles 
        // that have been minted for specific CollectibleItems in this Set.
        // When a Collectible is minted, this value is stored in the Collectible to
        // show its place in the Set, eg. 13 of 60.
        pub var numberMintedPerCollectibleItem: {UInt32: UInt32}

        init(name: String, setIdentityURL: String?, description: String?) {
            pre {
                name.length > 0: "New Set name cannot be empty"
            }

            self.setID = KOTD.nextSetID
            self.name = name
            self.setIdentityURL = setIdentityURL
            self.description = description
            self.series = KOTD.seriesDatas[KOTD.currentSeriesID]!
            self.collectibleItems = []
            self.retired = {}
            self.locked = false
            self.numberMintedPerCollectibleItem = {}

            KOTD.nextSetID = KOTD.nextSetID + UInt32(1)

            emit SetCreated(setID: self.setID, series: self.series.seriesID)
        }

        // addCollectibleItem adds a collectibleItem to the set
        //
        // Parameters: collectibleItemID: The ID of the CollectibleItem that is being added
        //
        // Pre-Conditions:
        // The CollectibleItem needs to be an existing collectibleItem
        // The Set needs to be not locked
        // The CollectibleItem can't have already been added to the Set
        
        pub fun addCollectibleItem(collectibleItemID: UInt32) {
            pre {
                KOTD.collectibleItemDatas[collectibleItemID] != nil: "Cannot add the CollectibleItem to Set: CollectibleItem doesn't exist."
                !self.locked: "Cannot add the collectibleItem to the Set after the set has been locked."
                self.numberMintedPerCollectibleItem[collectibleItemID] == nil: "The collectibleItem has already beed added to the set."
            }

            // Add the CollectibleItem to the array of CollectibleItems
            self.collectibleItems.append(collectibleItemID)

            // Open the CollectibleItem up for minting
            self.retired[collectibleItemID] = false

            // Initialize the Collectible count to zero
            self.numberMintedPerCollectibleItem[collectibleItemID] = 0

            emit CollectibleItemAddedToSet(setID: self.setID, collectibleItemID: collectibleItemID)
        }

        // addCollectibleItems adds multiple CollectibleItems to the Set
        //
        // Parameters: collectibleItemIDs: The IDs of the CollectibleItems that are being added
        //                      as an array
        
        pub fun addCollectibleItems(collectibleItemIDs: [UInt32]) {
            for collectibleItem in collectibleItemIDs {
                self.addCollectibleItem(collectibleItemID: collectibleItem)
            }
        }

        // retireCollectibleItem retires a CollectibleItem from the Set so that it can't mint new Collectibles
        //
        // Parameters: collectibleItemID: The ID of the CollectibleItem that is being retired
        //
        // Pre-Conditions:
        // The CollectibleItem is part of the Set and not retired (available for minting).
        
        pub fun retireCollectibleItem(collectibleItemID: UInt32) {
            pre {
                self.retired[collectibleItemID] != nil: "Cannot retire the CollectibleItem: CollectibleItem doesn't exist in this set!"
            }

            if !self.retired[collectibleItemID]! {
                self.retired[collectibleItemID] = true

                emit CollectibleItemRetiredFromSet(setID: self.setID, collectibleItemID: collectibleItemID, numCollectibleItems: self.numberMintedPerCollectibleItem[collectibleItemID]!)
            }
        }

        // retireAll retires all the collectibleItems in the Set
        // Afterwards, none of the retired CollectibleItems will be able to mint new Collectibles
        
        pub fun retireAll() {
            for collectibleItem in self.collectibleItems {
                self.retireCollectibleItem(collectibleItemID: collectibleItem)
            }
        }

        // lock() locks the Set so that no more CollectibleItems can be added to it
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
        // Parameters: collectibleItemID: The ID of the CollectibleItem that the Collectible references
        //
        // Pre-Conditions:
        // The CollectibleItem must exist in the Set and be allowed to mint new Collectibles
        //
        // Returns: The NFT that was minted
        
        pub fun mintCollectible(collectibleItemID: UInt32): @NFT {
            pre {
                self.retired[collectibleItemID] != nil: "Cannot mint the collectibleItem: This collectibleItem doesn't exist."
                !self.retired[collectibleItemID]!: "Cannot mint the collectibleItem from this collectibleItem: This collectibleItem has been retired."
            }

            // Gets the number of Collectibles that have been minted for this CollectibleItem
            // to use as this Collectible's serial number
            let numInPlay = self.numberMintedPerCollectibleItem[collectibleItemID]!

            // Mint the new collectibleItem
            let newCollectible: @NFT <- create NFT(serialNumber: numInPlay + UInt32(1),
                                              collectibleItemID: collectibleItemID,
                                              setID: self.setID)

            // Increment the count of Collectibles minted for this CollectibleItem
            self.numberMintedPerCollectibleItem[collectibleItemID] = numInPlay + UInt32(1)

            return <-newCollectible
        }

        // batchMintCollectible mints an arbitrary quantity of Collectibles 
        // and returns them as a Collection
        //
        // Parameters: collectibleItemID: the ID of the CollectibleItem that the Collectibles are minted for
        //             quantity: The quantity of Collectibles to be minted
        //
        // Returns: Collection object that contains all the Collectibles that were minted
        
        pub fun batchMintCollectible(collectibleItemID: UInt32, quantity: UInt64): @Collection {
            let newCollection <- create Collection()

            var i: UInt64 = 0
            while i < quantity {
                newCollection.deposit(token: <-self.mintCollectible(collectibleItemID: collectibleItemID))
                i = i + UInt64(1)
            }

            return <-newCollection
        }
    }

    pub struct CollectibleData {

        // The ID of the Set that the Collectible comes from
        pub let setID: UInt32

        // The ID of the CollectibleItem that the Collectible references
        pub let collectibleItemID: UInt32

        // The place in the edition that this Collectible was minted
        // Otherwise know as the serial number
        pub let serialNumber: UInt32

        init(setID: UInt32, collectibleItemID: UInt32, serialNumber: UInt32) {
            self.setID = setID
            self.collectibleItemID = collectibleItemID
            self.serialNumber = serialNumber
        }

    }


    // Admin is a special authorization resource that 
    // allows the owner to perform important functions to modify the 
    // various aspects of the CollectibleItems, Sets, and Collectibles  
    pub resource Admin {

        // createCollectibleItem creates a new CollectibleItem struct 
        // and stores it in the CollectibleItems dictionary in the KOTD smart contract
        //
        // Parameters: metadata: A dictionary mapping metadata titles to their data
        //                       example: {"Player Name": "Kevin Durant", "Height": "7 feet"}
        //                               (because we all know Kevin Durant is not 6'9")
        //
        // Returns: the ID of the new CollectibleItem object

        pub fun createCollectibleItem(metadata: {String: String}): UInt32 {
            // Create the new CollectibleItem
            var newCollectibleItem = CollectibleItem(metadata: metadata)
            let newID = newCollectibleItem.collectibleItemID

            // Store it in the contract storage
            KOTD.collectibleItemDatas[newID] = newCollectibleItem

            return newID
        }

        // createSet creates a new Set resource and stores it
        // in the sets mapping in the KOTD contract
        //
        // Parameters: name: The name of the Set
        
        pub fun createSet(name: String, setIdentityURL: String?, description: String?) {
            // Create the new Set
            var newSet <- create Set(name: name, setIdentityURL: setIdentityURL, description: description)

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
        
        pub fun startNewSeries(name: String?, identityURL: String?): UInt32 {
            // End the current series and start a new one
            // by incrementing the KOTD series number


            var newSeries = Series(seriesID: KOTD.currentSeriesID + UInt32(1), name: name, seriesIdentityURL: identityURL)

            KOTD.currentSeriesID = newSeries.seriesID

            //put it in storage
            KOTD.seriesDatas[KOTD.currentSeriesID] = newSeries


            emit NewSeriesStarted(newCurrentSeries: KOTD.currentSeriesID)

            return KOTD.currentSeriesID
        }

        // createNewAdmin creates a new Admin resource
        pub fun createNewAdmin(): @Admin {
            return <-create Admin()
        }
    }

    // The resource that represents the Collectible NFTs
    pub resource NFT: NonFungibleToken.INFT {

        // Global unique collectibleItem ID
        pub let id: UInt64
        
        // Struct of Collectible metadata
        pub let data: CollectibleData

        init(serialNumber: UInt32, collectibleItemID: UInt32, setID: UInt32) {
            // Increment the global Collectible IDs
            KOTD.totalSupply = KOTD.totalSupply + UInt64(1)

            self.id = KOTD.totalSupply

            // Set the metadata struct
            self.data = CollectibleData(setID: setID, collectibleItemID: collectibleItemID, serialNumber: serialNumber)

            emit CollectibleMinted(collectibleID: self.id, collectibleItemID: collectibleItemID, setID: self.data.setID, serialNumber: self.data.serialNumber)
        }

        // If the Collectible is destroyed, emit an event to indicate 
        // to outside observers that it has been destroyed
        destroy() {
            emit CollectibleDestroyed(id: self.id)
        }
    }


    // This is the interface that users can cast their Collectible Collection as
    // to allow others to deposit Collectibles into their Collection. It also allows for reading
    // the IDs of Collectibles in the Collection.
    pub resource interface NiftoryCollectibleCollectionPublic {
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
    pub resource Collection: NiftoryCollectibleCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic { 
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
        //                                        the withdrawn collectibleItems
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
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowCollectible returns a borrowed reference to a Collectible
        // so that the caller can read data and call methods from it.
        // They can use this to read its setID, collectibleItemID, serialNumber,
        // or any of the setData or CollectibleItem data associated with it by
        // getting the setID or collectibleItemID and reading those fields from
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
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <-create KOTD.Collection()
    }

    // getAllCollectibleItems returns all the collectibleItems in KOTD
    //
    // Returns: An array of all the collectibleItems that have been created
    pub fun getAllCollectibleItems(): [KOTD.CollectibleItem] {
        return KOTD.collectibleItemDatas.values
    }

    // getCollectibleItemMetaData returns all the metadata associated with a specific CollectibleItem
    // 
    // Parameters: collectibleItemID: The id of the CollectibleItem that is being searched
    //
    // Returns: The metadata as a String to String mapping optional
    pub fun getCollectibleItemMetaData(collectibleItemID: UInt32): {String: String}? {
        return self.collectibleItemDatas[collectibleItemID]?.metadata
    }

    // getCollectibleItemMetaDataByField returns the metadata associated with a 
    //                        specific field of the metadata
    //                        Ex: field: "Team" will return something
    //                        like "Memphis Grizzlies"
    // 
    // Parameters: collectibleItemID: The id of the CollectibleItem that is being searched
    //             field: The field to search for
    //
    // Returns: The metadata field as a String Optional
    pub fun getCollectibleItemMetaDataByField(collectibleItemID: UInt32, field: String): String? {
        // Don't force a revert if the collectibleItemID or field is invalid
        if let collectibleItem = KOTD.collectibleItemDatas[collectibleItemID] {
            return collectibleItem.metadata[field]
        } else {
            return nil
        }
    }

    // getCollectibleItemsInSet returns the list of CollectibleItem IDs that are in the Set
    // 
    // Parameters: setID: The id of the Set that is being searched
    //
    // Returns: An array of CollectibleItem IDs
    pub fun getCollectibleItemsInSet(setID: UInt32): [UInt32]? {
        // Don't force a revert if the setID is invalid
        return KOTD.sets[setID]?.collectibleItems
    }

    // isEditionRetired returns a boolean that indicates if a Set/CollectibleItem combo
    //                  (otherwise known as an edition) is retired.
    //                  If an edition is retired, it still remains in the Set,
    //                  but Collectibles can no longer be minted from it.
    // 
    // Parameters: setID: The id of the Set that is being searched
    //             collectibleItemID: The id of the CollectibleItem that is being searched
    //
    // Returns: Boolean indicating if the edition is retired or not
    pub fun isEditionRetired(setID: UInt32, collectibleItemID: UInt32): Bool? {
        // Don't force a revert if the set or collectibleItem ID is invalid
        // Remove the set from the dictionary to get its field
        if let setToRead <- KOTD.sets.remove(key: setID) {

            // See if the CollectibleItem is retired from this Set
            let retired = setToRead.retired[collectibleItemID]

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
    //             new CollectibleItems can no longer be added to it,
    //             but Collectibles can still be minted from CollectibleItems the set contains.
    // 
    // Parameters: setID: The id of the Set that is being searched
    //
    // Returns: Boolean indicating if the Set is locked or not
    pub fun isSetLocked(setID: UInt32): Bool? {
        // Don't force a revert if the setID is invalid
        return KOTD.sets[setID]?.locked
    }

    // @TODO: refactor to "getNumCollectiblesInEdition"
    // getNumCollectibleItemsInEdition return the number of Collectibles that have been 
    //                        minted from a certain edition.
    //
    // Parameters: setID: The id of the Set that is being searched
    //             collectibleItemID: The id of the CollectibleItem that is being searched
    //
    // Returns: The total number of Collectibles 
    //          that have been minted from an edition
    pub fun getNumCollectibleItemsInEdition(setID: UInt32, collectibleItemID: UInt32): UInt32? {
        // Don't force a revert if the Set or collectibleItem ID is invalid
        // Remove the Set from the dictionary to get its field
        if let setToRead <- KOTD.sets.remove(key: setID) {

            // Read the numMintedPerPlay
            let amount = setToRead.numberMintedPerCollectibleItem[collectibleItemID]

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
        self.currentSeriesID = 0
        self.seriesDatas = {}
        self.seriesDatas[self.currentSeriesID] = (Series(seriesID: KOTD.currentSeriesID, name: nil, seriesIdentityURL: nil))
        self.collectibleItemDatas = {}
        self.sets <- {}
        self.nextCollectibleItemID = 1
        self.nextSetID = 1
        self.totalSupply = 0

        // initialize paths
        // Set our named paths
        self.CollectionStoragePath = /storage/NiftoryCollectibleCollection
        self.CollectionPublicPath = /public/NiftoryCollectibleCollection
        self.AdminStoragePath = /storage/KOTDAdmin003

        // Put a new Collection in storage 
        self.account.save<@Collection>(<- create Collection(), to: self.CollectionStoragePath)

        // Create a public capability for the Collection
        self.account.link<&{NiftoryCollectibleCollectionPublic}>(self.CollectionPublicPath, target: self.CollectionStoragePath)

        // Put the Minter in storage
        self.account.save<@Admin>(<- create Admin(), to: self.AdminStoragePath)

        emit ContractInitialized()
    }
}