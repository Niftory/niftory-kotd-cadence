// This script returns an array of all the NFT IDs in an account's collection.

transaction {
    prepare(signer: AuthAccount) {
        let NFTContractRemover = signer.contracts.remove(name: "LikeNastyaItems")
        let NFTContractRemover2 = signer.contracts.remove(name: "Dollar")
        let NFTContractRemover3 = signer.contracts.remove(name: "LikeNastyaItemsMarket")
    }
}
