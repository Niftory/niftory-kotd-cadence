import KOTD from 0x9f3e19cda04154fc

// This is the script to get a list of all the Collectibles' serials an account owns
// Just change the argument to `getAccount` to whatever account you want
// and as long as they have a published Collection receiver, you can see
// the Collectibles they own.

// Parameters:
//
// account: The Flow Address of the account whose Collectible data needs to be read

// Returns: [UInt64]
// list of all Collectibles' serials an account owns

pub fun main(account: Address): [UInt32] {

    let acct = getAccount(account)

    let collectionRef = acct.getCapability(/public/CollectibleCollection)
                            .borrow<&{KOTD.CollectibleCollectionPublic}>()!

    log(collectionRef.getIDs())

    var serials: [UInt32] = []


    for id in collectionRef.getIDs() {
        let token = collectionRef.borrowCollectible(id: id)
        ?? panic("Could not borrow a reference to the specified Collectible")

        let data = token.data

        serials.append(data.serialNumber)
    }

    return serials
}