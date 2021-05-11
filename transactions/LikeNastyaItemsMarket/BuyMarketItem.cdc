    import FlowToken from 0x7e60df042a9c0868
    import LikeNastyaItems from 0x9f3e19cda04154fc
    import FungibleToken from 0x9a0766d93b6608b7
    import NonFungibleToken from 0x631e88ae7f1d7c20
    import LikeNastyaItemsMarket from 0x9f3e19cda04154fc

transaction() {
    let paymentVault: @FungibleToken.Vault
    let likeNastyaItemsCollection: &LikeNastyaItems.Collection{NonFungibleToken.Receiver}
    let marketCollection: &LikeNastyaItemsMarket.Collection{LikeNastyaItemsMarket.CollectionPublic}

    prepare(signer: AuthAccount) {
        self.marketCollection = getAccount(0x771025a691b50148)
            .getCapability<&LikeNastyaItemsMarket.Collection{LikeNastyaItemsMarket.CollectionPublic}>(
                LikeNastyaItemsMarket.CollectionPublicPath
            )!
            .borrow()
            ?? panic("Could not borrow market collection from market address")

        let saleItem = self.marketCollection.borrowSaleItem(itemID: UInt64(3))
                    ?? panic("No item with that ID")
        let price = saleItem.price

        let mainFlowVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Cannot borrow FlowToken vault from acct storage")
        self.paymentVault <- mainFlowVault.withdraw(amount: price)

        self.likeNastyaItemsCollection = signer.borrow<&LikeNastyaItems.Collection{NonFungibleToken.Receiver}>(
            from: LikeNastyaItems.CollectionStoragePath
        ) ?? panic("Cannot borrow LikeNastyaItems collection receiver from acct")
    }

    execute {
        self.marketCollection.purchase(
            itemID: UInt64(3),
            buyerCollection: self.likeNastyaItemsCollection,
            buyerPayment: <- self.paymentVault
        )
    }
}