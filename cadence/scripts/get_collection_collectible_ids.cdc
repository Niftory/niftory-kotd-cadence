import KOTD from "../contracts/KOTD.cdc"

// This is the script to get a list of all the Collectible ids an account owns
// Just change the argument to `getAccount` to whatever account you want
// and as long as they have a published Collection receiver, you can see
// the moments they own.

// Parameters:
//
// account: The Flow Address of the account whose Collectible data needs to be read

// Returns: [UInt64]
// list of all moments' ids an account owns

pub fun main(account: Address): [UInt64] {

    let acct = getAccount(account)

    let collectionRef = acct.getCapability(KOTD.CollectionPublicPath)
                            .borrow<&{KOTD.NiftoryCollectibleCollectionPublic}>()!

    log(collectionRef.getIDs())

    return collectionRef.getIDs()
}