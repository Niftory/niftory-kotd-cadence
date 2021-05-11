import LikeNastyaItems from 0x9f3e19cda04154fc
import NonFungibleToken from 0x631e88ae7f1d7c20

// This script returns the metadata for an NFT in an account's collection.

pub fun main(id: UInt64): {String : String} {

    // get the public account object for the token owner
    let owner = getAccount(0x9f3e19cda04154fc)

    let collectionBorrow = owner.getCapability(LikeNastyaItems.CollectionPublicPath)!
        .borrow<&{LikeNastyaItems.LikeNastyaItemsCollectionPublic}>()
        ?? panic("Could not borrow LastNastyaItemsCollectionPublic")

    // borrow a reference to a specific NFT in the collection
    let likeNastyaItem = collectionBorrow.borrowLikeNastyaItem(id: id)
        ?? panic("No such itemID in that collection")

    return likeNastyaItem.metadata
}