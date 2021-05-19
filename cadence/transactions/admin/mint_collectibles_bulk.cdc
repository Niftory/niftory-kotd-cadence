import KOTD from "../../contracts/KOTD.cdc"

// This transaction mints multiple moments 
// from a single set/play combination (otherwise known as edition)

// Parameters:
//
// setID: the ID of the set to be minted from
// collectibleItemID: the ID of the Play from which the Moments are minted 
// quantity: the quantity of Moments to be minted
// recipientAddr: the Flow address of the account receiving the collection of minted moments

transaction(setID: UInt32, collectibleItemID: UInt32, quantity: UInt64, recipientAddr: Address) {

    // Local variable for the topshot Admin object
    let adminRef: &KOTD.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&KOTD.Admin>(from: /storage/KOTDAdmin002)!
    }

    execute {

        // borrow a reference to the set to be minted from
        let setRef = self.adminRef.borrowSet(setID: setID)

        // Mint all the new NFTs
        let collection <- setRef.batchMintCollectible(collectibleItemID: collectibleItemID, quantity: quantity)

        // Get the account object for the recipient of the minted tokens
        let recipient = getAccount(recipientAddr)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(/public/CollectibleCollection).borrow<&{KOTD.CollectibleCollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's collection")

        // deposit the NFT in the receivers collection
        receiverRef.batchDeposit(tokens: <-collection)
    }
}