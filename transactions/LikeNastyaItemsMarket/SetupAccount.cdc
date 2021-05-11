import LikeNastyaItemsMarket from 0x9f3e19cda04154fc

// This transaction configures an account to hold SaleOffer items.

transaction {
    prepare(signer: AuthAccount) {

        // if the account doesn't already have a collection
        if signer.borrow<&LikeNastyaItemsMarket.Collection>(from: LikeNastyaItemsMarket.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- LikeNastyaItemsMarket.createEmptyCollection() as! @LikeNastyaItemsMarket.Collection

            // save it to the account
            signer.save(<-collection, to: LikeNastyaItemsMarket.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&LikeNastyaItemsMarket.Collection{LikeNastyaItemsMarket.CollectionPublic}>(LikeNastyaItemsMarket.CollectionPublicPath, target: LikeNastyaItemsMarket.CollectionStoragePath)
        }
    }
}