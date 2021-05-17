import KOTD from "../contracts/KOTD.cdc"

// This script returns the number of specified Collectibles that have been
// minted for the specified edition

// Parameters:
//
// setID: The unique ID for the set whose data needs to be read
// collectibleItemID: The unique ID for the play whose data needs to be read

// Returns: UInt32
// number of Collectibles with specified collectibleItemID minted for a set with specified setID

pub fun main(setID: UInt32, collectibleItemID: UInt32): UInt32 {

    let editionSize = KOTD.getNumCollectibleItemsInEdition(setID: setID, collectibleItemID: collectibleItemID)
        ?? panic("Could not find the specified edition")

    return editionSize
}