import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import KOTD from "../../contracts/KOTD.cdc"

// This transaction sets up an account to collect KOTD collectibles
// by storing an empty KOTD collectible collection and creating
// a public capability for it

transaction {

    prepare(acct: AuthAccount) {

        // First, check to see if a KOTD collectible collection already exists
        if acct.borrow<&KOTD.Collection>(from: KOTD.CollectionStoragePath) == nil {

            // create a new KOTD Collection
            let collection <- KOTD.createEmptyCollection() as! @KOTD.Collection

            // Put the new Collection in storage
            acct.save(<-collection, to: KOTD.CollectionStoragePath)

            // create a public capability for the collection
            acct.link<&{KOTD.NiftoryCollectibleCollectionPublic}>(KOTD.CollectionPublicPath, target: KOTD.CollectionStoragePath)

        }
    }
}