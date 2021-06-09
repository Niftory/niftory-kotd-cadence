
import KOTD from "../../contracts/KOTD.cdc"

// This transaction sets up an account to use Top Shot
// by storing an empty moment collection and creating
// a public capability for it

transaction {

    prepare(acct: AuthAccount) {

        // First, check to see if a moment collection already exists
        if acct.borrow<&KOTD.Collection>(from: /storage/CollectibleCollection003) == nil {

            // create a new TopShot Collection
            let collection <- KOTD.createEmptyCollection() as! @KOTD.Collection

            // Put the new Collection in storage
            acct.save(<-collection, to: /storage/CollectibleCollection003)

            // create a public capability for the collection
            acct.link<&{KOTD.CollectibleCollectionPublic}>(/public/CollectibleCollection003, target: /storage/CollectibleCollection003)
        }
    }
}