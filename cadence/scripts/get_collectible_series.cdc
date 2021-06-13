import KOTD from "../contracts/KOTD.cdc"

// This script gets the Series associated with a Collectible
// in a collection by getting a reference to the Collectible
// and then looking up its series

// Parameters:
//
// account: The Flow Address of the account whose Collectible data needs to be read
// id: The unique ID for the Collectible whose data needs to be read

// Returns: KOTD.Series
// The Series associated with a Collectible with a specified ID

pub fun main(account: Address, id: UInt64): KOTD.Series {

    let collectionRef = getAccount(account).getCapability(KOTD.CollectionPublicPath)
        .borrow<&{KOTD.NiftoryCollectibleCollectionPublic}>()
        ?? panic("Could not get public KOTD collection reference")

    let token = collectionRef.borrowCollectible(id: id)
        ?? panic("Could not borrow a reference to the specified Collectible")

    let data = token.data

    return KOTD.SetData(setID: data.setID).series
}