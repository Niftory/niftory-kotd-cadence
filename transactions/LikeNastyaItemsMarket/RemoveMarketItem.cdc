import LikeNastyaItemsMarket from "../../contracts/LikeNastyaItemsMarket.cdc"

transaction(itemID: UInt64) {
    let marketCollection: &LikeNastyaItemsMarket.Collection

    prepare(signer: AuthAccount) {
        self.marketCollection = signer.borrow<&LikeNastyaItemsMarket.Collection>(from: LikeNastyaItemsMarket.CollectionStoragePath)
            ?? panic("Missing or mis-typed LikeNastyaItemsMarket Collection")
    }

    execute {
        let offer <-self.marketCollection.remove(itemID: itemID)
        destroy offer
    }
}