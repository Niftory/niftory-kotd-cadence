import NonFungibleToken from 0x631e88ae7f1d7c20

// LikeNastyaItems
// NFT items for LikeNastya!
//
pub contract LikeNastyaItems: NonFungibleToken {

    // Events
    //
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64, typeID: UInt64)

    // Named Paths
    //
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    // totalSupply
    // The total number of LikeNastyaItems that have been minted
    //
    pub var totalSupply: UInt64

    // NFT
    // A LikeNastya Item as an NFT
    //
    pub resource NFT: NonFungibleToken.INFT {
        // The token's ID
        pub let id: UInt64
        // The token's type, e.g. 3 == Hat
        pub let typeID: UInt64

        pub let metadata: { String : String}

        // initializer
        //
        init(initID: UInt64, initTypeID: UInt64, metadata: {String : String}) {
            self.id = initID
            self.typeID = initTypeID
            self.metadata = metadata;
        }
    }

    // This is the interface that users can cast their LikeNastyaItems Collection as
    // to allow others to deposit LikeNastyaItems into their Collection. It also allows for reading
    // the details of LikeNastyaItems in the Collection.
    pub resource interface LikeNastyaItemsCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowLikeNastyaItem(id: UInt64): &LikeNastyaItems.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow LikeNastyaItem reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // Collection
    // A collection of LikeNastyaItem NFTs owned by an account
    //
    pub resource Collection: LikeNastyaItemsCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        //
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
        pub var metadataObjs: {UInt64: { String : String }}


        // withdraw
        // Removes an NFT from the collection and moves it to the caller
        //
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            //assert(self.ownedNFTs[0] != nil, message: "Array of keys is zero length.")
            /*if self.ownedNFTs[withdrawID] == nil {
                assert(false, message: "Key does not exist.")
            }*/
            
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit
        // Takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @LikeNastyaItems.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs
        // Returns an array of the IDs that are in the collection
        //
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT
        // Gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowLikeNastyaItem
        // Gets a reference to an NFT in the collection as a LikeNastyaItem,
        // exposing all of its fields (including the typeID).
        // This is safe as there are no functions that can be called on the LikeNastyaItem.
        //
        pub fun borrowLikeNastyaItem(id: UInt64): &LikeNastyaItems.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &LikeNastyaItems.NFT
            } else {
                return nil
            }
        }

        // destructor
        destroy() {
            destroy self.ownedNFTs
        }

        // initializer
        //
        init () {
            self.ownedNFTs <- {}
            self.metadataObjs = {}
        }
    }

    // createEmptyCollection
    // public function that anyone can call to create a new empty collection
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // NFTMinter
    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
	pub resource NFTMinter {

		// mintNFT
        // Mints a new NFT with a new ID
		// and deposit it in the recipients collection using their collection reference
        //
		pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, typeID: UInt64, metadata: {String : String}) {
            emit Minted(id: LikeNastyaItems.totalSupply, typeID: typeID)

			// deposit it in the recipient's account using their reference
			recipient.deposit(token: <-create LikeNastyaItems.NFT(initID: LikeNastyaItems.totalSupply, initTypeID: typeID, metadata: metadata))

            LikeNastyaItems.totalSupply = LikeNastyaItems.totalSupply + (1 as UInt64)
		}
	}

    // fetch
    // Get a reference to a LikeNastyaItem from an account's Collection, if available.
    // If an account does not have a LikeNastyaItems.Collection, panic.
    // If it has a collection but does not contain the itemID, return nil.
    // If it has a collection and that collection contains the itemID, return a reference to that.
    //
    pub fun fetch(_ from: Address, itemID: UInt64): &LikeNastyaItems.NFT? {
        let collection = getAccount(from)
            .getCapability(LikeNastyaItems.CollectionPublicPath)!
            .borrow<&LikeNastyaItems.Collection{LikeNastyaItems.LikeNastyaItemsCollectionPublic}>()
            ?? panic("Couldn't get collection")
        // We trust LikeNastyaItems.Collection.borowLikeNastyaItem to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowLikeNastyaItem(id: itemID)
    }

    // initializer
    //
	init() {
        // Set our named paths
        //FIXME: REMOVE SUFFIX BEFORE RELEASE
        self.CollectionStoragePath = /storage/LikeNastyaItemsCollection008
        self.CollectionPublicPath = /public/LikeNastyaItemsCollection008
        self.MinterStoragePath = /storage/LikeNastyaItemsMinter008

        // Initialize the total supply
        self.totalSupply = 0

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
	}
}