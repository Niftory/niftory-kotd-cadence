import KOTD from "../../contracts/KOTD.cdc"

// This transaction is what an admin would use to mint a single new collectibleItem
// and deposit it in a user's collection

// Parameters:
//
// setID: the ID of a set containing the target play
// collectibleItemID: the ID of a play from which a new collectibleItem is minted
// recipientAddr: the Flow address of the account receiving the newly minted collectibleItem

transaction(setID: UInt32, collectibleItemID: UInt32, recipientAddr: Address) {
    // local variable for the admin reference
    let adminRef: &KOTD.Admin

    prepare(acct: AuthAccount) {
        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&KOTD.Admin>(from: /storage/KOTDAdmin003)!
    }

    execute {
        // Borrow a reference to the specified set
        let setRef = self.adminRef.borrowSet(setID: setID)

        // Mint a new NFT
        let collectible <- setRef.mintCollectible(collectibleItemID: collectibleItemID)

        // get the public account object for the recipient
        let recipient = getAccount(recipientAddr)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(/public/NiftoryCollectibleCollection).borrow<&{KOTD.NiftoryCollectibleCollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's collectible collection")

        // deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-collectible)
    }
}