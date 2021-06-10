import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import KOTD from "../../contracts/KOTD.cdc"

// This transaction transfers a number of moments to a recipient

// Parameters
//
// recipientAddress: the Flow address who will receive the NFTs
// collectibleIDs: an array of moment IDs of NFTs that recipient will receive

transaction(recipientAddress: Address, collectibleIDs: [UInt64]) {

    let transferTokens: @NonFungibleToken.Collection
    
    prepare(acct: AuthAccount) {

        self.transferTokens <- acct.borrow<&KOTD.Collection>(from: KOTD.CollectionStoragePath)!.batchWithdraw(ids: collectibleIDs)
    }

    execute {
        
        // get the recipient's public account object
        let recipient = getAccount(recipientAddress)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(KOTD.CollectionPublicPath).borrow<&{KOTD.NiftoryCollectibleCollectionPublic}>()
            ?? panic("Could not borrow a reference to the recipients moment receiver")

        // deposit the NFT in the receivers collection
        receiverRef.batchDeposit(tokens: <-self.transferTokens)
    }
}