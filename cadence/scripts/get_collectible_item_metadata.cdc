import KOTD from "../contracts/KOTD.cdc"

// This script returns the full metadata associated with a Collectible Item
// in the KOTD smart contract

// Parameters:
//
// collectibleItemID: The unique ID for the play whose data needs to be read

// Returns: {String:String}
// A dictionary of all the play metadata associated
// with the specified collectibleItemID

pub fun main(collectibleItemID: UInt32): {String:String} {

    let metadata = KOTD.getCollectibleItemMetaData(collectibleItemID: collectibleItemID) ?? panic("Play doesn't exist")

    log(metadata)

    return metadata
}