import KOTD from "../contracts/KOTD.cdc"

pub fun main(address: Address): Bool {

    return getAccount(address)
        .getCapability<&{KOTD.NiftoryCollectibleCollectionPublic}>(KOTD.CollectionPublicPath)
        .check()
}