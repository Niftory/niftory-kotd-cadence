  import FlowToken from 0x7e60df042a9c0868
    import LikeNastyaItems from 0x9f3e19cda04154fc
    import FungibleToken from 0x9a0766d93b6608b7
    import NonFungibleToken from 0x631e88ae7f1d7c20
    import LikeNastyaItemsMarket from 0x9f3e19cda04154fc


    pub fun main(): UInt64 {
    let marketCollectionRef = getAccount(0x771025a691b50148)
        .getCapability<&LikeNastyaItemsMarket.Collection{LikeNastyaItemsMarket.CollectionPublic}>(
            LikeNastyaItemsMarket.CollectionPublicPath
        )!
        .borrow()
        ?? panic("Could not borrow market collection from market address")

    let saleItem = marketCollectionRef.borrowSaleItem(itemID: UInt64(3))
                ?? panic("No item with that ID")
    
    return saleItem.itemID;
}