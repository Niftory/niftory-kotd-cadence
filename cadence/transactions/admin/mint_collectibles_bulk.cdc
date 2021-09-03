import KOTD from "../../contracts/KOTD.cdc"

// This transaction mints multiple moments 
// from a single set/collectible item combination (otherwise known as edition)

// Parameters:
//
// setID: the ID of the set to be minted from
// collectibleItemID: the ID of the Collectible Item from which the Collectibles are minted 
// quantity: the quantity of Collectibles to be minted
// recipientAddr: the Flow address of the account receiving the collection of minted Collectibles

transaction(setID: UInt32, collectibleItemID: UInt32, quantity: UInt64, recipientAddr: Address) {

    // Local variable for the topshot Admin object
    let adminRef: &KOTD.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&KOTD.Admin>(from: KOTD.AdminStoragePath)!
    }

    execute {

        // borrow a reference to the set to be minted from
        let setRef = self.adminRef.borrowSet(setID: setID)

        // Mint all the new NFTs
        let collection <- setRef.batchMintCollectible(collectibleItemID: collectibleItemID, quantity: quantity)

        // Get the account object for the recipient of the minted tokens
        let recipient = getAccount(recipientAddr)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(KOTD.CollectionPublicPath).borrow<&{KOTD.NiftoryCollectibleCollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's collection")

        // deposit the NFT in the receivers collection
        receiverRef.batchDeposit(tokens: <-collection)
    }
}