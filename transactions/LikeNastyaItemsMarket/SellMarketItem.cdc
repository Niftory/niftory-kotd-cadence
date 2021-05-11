import Dollar from 0x9f3e19cda04154fc
import LikeNastyaItems from 0x9f3e19cda04154fc
import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import LikeNastyaItemsMarket from 0x9f3e19cda04154fc

transaction(itemID: UInt64, price: UFix64) {
    let dollarVault: Capability<&Dollar.Vault{FungibleToken.Receiver}>
    let likeNastyaItemsCollection: Capability<&LikeNastyaItems.Collection{NonFungibleToken.Provider, LikeNastyaItems.LikeNastyaItemsCollectionPublic}>
    let marketCollection: &LikeNastyaItemsMarket.Collection

    prepare(signer: AuthAccount) {
        // we need a provider capability, but one is not provided by default so we create one.
        let LikeNastyaItemsCollectionProviderPrivatePath = /private/LikeNastyaItemsCollectionProvider

        self.dollarVault = signer.getCapability<&Dollar.Vault{FungibleToken.Receiver}>(Dollar.ReceiverPublicPath)!
        assert(self.dollarVault.borrow() != nil, message: "Missing or mis-typed Dollar receiver")

        if !signer.getCapability<&LikeNastyaItems.Collection{NonFungibleToken.Provider, LikeNastyaItems.LikeNastyaItemsCollectionPublic}>(LikeNastyaItemsCollectionProviderPrivatePath)!.check() {
            signer.link<&LikeNastyaItems.Collection{NonFungibleToken.Provider, LikeNastyaItems.LikeNastyaItemsCollectionPublic}>(LikeNastyaItemsCollectionProviderPrivatePath, target: LikeNastyaItems.CollectionStoragePath)
        }

        self.likeNastyaItemsCollection = signer.getCapability<&LikeNastyaItems.Collection{NonFungibleToken.Provider, LikeNastyaItems.LikeNastyaItemsCollectionPublic}>(LikeNastyaItemsCollectionProviderPrivatePath)!
        assert(self.likeNastyaItemsCollection.borrow() != nil, message: "Missing or mis-typed LikeNastyaItemsCollection provider")

        self.marketCollection = signer.borrow<&LikeNastyaItemsMarket.Collection>(from: LikeNastyaItemsMarket.CollectionStoragePath)
            ?? panic("Missing or mis-typed LikeNastyaItemsMarket Collection")
    }

    execute {
        let offer <- LikeNastyaItemsMarket.createSaleOffer (
            sellerItemProvider: self.likeNastyaItemsCollection,
            itemID: itemID,
            typeID: self.likeNastyaItemsCollection.borrow()!.borrowLikeNastyaItem(id: itemID)!.typeID,
            sellerPaymentReceiver: self.dollarVault,
            price: price
        )
        self.marketCollection.insert(offer: <-offer)
    }
}