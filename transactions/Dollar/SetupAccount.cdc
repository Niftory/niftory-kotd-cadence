import FungibleToken from "../../contracts/FungibleToken.cdc"
import Dollar from "../../contracts/Dollar.cdc"

// This transaction is a template for a transaction
// to add a Vault resource to their account
// so that they can use the Dollar

transaction {

    prepare(signer: AuthAccount) {

        if signer.borrow<&Dollar.Vault>(from: Dollar.VaultStoragePath) == nil {
            // Create a new Dollar Vault and put it in storage
            signer.save(<-Dollar.createEmptyVault(), to: Dollar.VaultStoragePath)

            // Create a public capability to the Vault that only exposes
            // the deposit function through the Receiver interface
            signer.link<&Dollar.Vault{FungibleToken.Receiver}>(
                Dollar.ReceiverPublicPath,
                target: Dollar.VaultStoragePath
            )

            // Create a public capability to the Vault that only exposes
            // the balance field through the Balance interface
            signer.link<&Dollar.Vault{FungibleToken.Balance}>(
                Dollar.BalancePublicPath,
                target: Dollar.VaultStoragePath
            )
        }
    }
}