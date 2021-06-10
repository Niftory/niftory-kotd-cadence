import KOTD from "../contracts/KOTD.cdc"

// This script returns the full metadata associated with a CollectibleItem
// in the KOTD smart contract

// Parameters:
//
// collectibleItemID: The unique ID for the play whose data needs to be read

// Returns: {String:String}
// A dictionary of all the play metadata associated
// with the specified collectibleItemID

pub fun main(collectibleItemID: UInt32): [String] {

    let featuredArtists = KOTD.getCollectibleItemFeaturedArtists(collectibleItemID: collectibleItemID) ?? panic("Play doesn't exist")

    log(featuredArtists)

    return featuredArtists
}