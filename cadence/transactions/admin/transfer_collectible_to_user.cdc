import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import KOTD from "../../contracts/KOTD.cdc"


// This transaction transfers a moment to a recipient

// This transaction is how a topshot user would transfer a moment
// from their account to another account
// The recipient must have a TopShot Collection object stored
// and a public MomentCollectionPublic capability stored at
// `/public/MomentCollection`

// Parameters:
//
// recipient: The Flow address of the account to receive the moment.
// withdrawID: The id of the moment to be transferred

transaction(recipient: Address, withdrawID: UInt64) {

    // local variable for storing the transferred token
    let transferToken: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        log("hello world")
        // borrow a reference to the owner's collection
        let collectionRef = acct.borrow<&KOTD.Collection>(from: KOTD.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the stored Moment collection")
                
        // withdraw the NFT
        self.transferToken <- collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {
        // get the recipient's public account object
        let recipient = getAccount(recipient)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(KOTD.CollectionPublicPath).borrow<&{KOTD.NiftoryCollectibleCollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's collectible collection")


        // deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-self.transferToken)
    }
}