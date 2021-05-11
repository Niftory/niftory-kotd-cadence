import LikeNastyaItems from 0x9f3e19cda04154fc
import NonFungibleToken from 0x631e88ae7f1d7c20

// This transaction configures an account to hold LikeNastya Items.

transaction {
    prepare(signer: AuthAccount) {
        // if the account doesn't already have a collection
        if signer.borrow<&LikeNastyaItems.Collection>(from: LikeNastyaItems.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- LikeNastyaItems.createEmptyCollection()

            // save it to the account
            signer.save(<-collection, to: LikeNastyaItems.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&LikeNastyaItems.Collection{NonFungibleToken.CollectionPublic, LikeNastyaItems.LikeNastyaItemsCollectionPublic}>(LikeNastyaItems.CollectionPublicPath, target: LikeNastyaItems.CollectionStoragePath)
        }
    }
}