
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import LikeNastyaItems from "../../contracts/LikeNastyaItems.cdc"

// This script returns the size of an account's LastNastyaItems collection.

pub fun main(address: Address): Int {
    let account = getAccount(address)

    let collectionRef = account.getCapability(LikeNastyaItems.CollectionPublicPath)!
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs().length
}