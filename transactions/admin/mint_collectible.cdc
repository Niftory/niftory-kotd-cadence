import KOTD from 0x9f3e19cda04154fc

// This transaction is what an admin would use to mint a single new moment
// and deposit it in a user's collection

// Parameters:
//
// setID: the ID of a set containing the target play
// momentID: the ID of a play from which a new moment is minted
// recipientAddr: the Flow address of the account receiving the newly minted moment

transaction(setID: UInt32, momentID: UInt32) {
    // local variable for the admin reference
    let adminRef: &KOTD.Admin

    prepare(acct: AuthAccount) {
        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&KOTD.Admin>(from: /storage/KOTDAdmin001)!
    }

    execute {
        // Borrow a reference to the specified set
        let setRef = self.adminRef.borrowSet(setID: setID)

        // Mint a new NFT
        let collectible <- setRef.mintCollectible(momentID: momentID)

        // get the public account object for the recipient
        let recipient = getAccount(0x9f3e19cda04154fc)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(/public/MomentCollection).borrow<&{KOTD.CollectibleCollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's collectible collection")

        // deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-collectible)
    }
}