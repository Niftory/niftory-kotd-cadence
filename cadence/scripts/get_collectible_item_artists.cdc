import KOTD from "../contracts/KOTD.cdc"

// This script returns the full metadata associated with a Collectible Item
// in the KOTD smart contract

// Parameters:
//
// collectibleItemID: The unique ID for the play whose data needs to be read

// Returns: [String]
// An array of all the artists featured
// in the specified Collectible Item

pub fun main(collectibleItemID: UInt32): [String] {

    let featuredArtists = KOTD.getCollectibleItemFeaturedArtists(collectibleItemID: collectibleItemID) ?? panic("Play doesn't exist")

    log(featuredArtists)

    return featuredArtists
}