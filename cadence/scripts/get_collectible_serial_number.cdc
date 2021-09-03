import KOTD from "../contracts/KOTD.cdc"

// This script gets the serial number of a Collectible
// by borrowing a reference to the Collectible 
// and returning its serial number

// Parameters:
//
// account: The Flow Address of the account whose Collectible data needs to be read
// id: The unique ID for the Collectible whose data needs to be read

// Returns: UInt32
// The serialNumber associated with a Collectible with a specified ID

pub fun main(account: Address, id: UInt64): UInt32 {

    let collectionRef = getAccount(account).getCapability(KOTD.CollectionPublicPath)
        .borrow<&{KOTD.NiftoryCollectibleCollectionPublic}>()
        ?? panic("Could not get public Collectible collection reference")

    let token = collectionRef.borrowCollectible(id: id)
        ?? panic("Could not borrow a reference to the specified Collectible")

    let data = token.data

    return data.serialNumber
}