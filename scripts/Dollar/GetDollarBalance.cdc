import Dollar from "../../contracts/Dollar.cdc"
import FungibleToken from "../../contracts/FungibleToken.cdc"

// This script returns an account's Dollar balance.

pub fun main(address: Address): UFix64 {
    let account = getAccount(address)
    
    let vaultRef = account.getCapability(Dollar.BalancePublicPath)!.borrow<&Dollar.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance reference to the Vault")

    return vaultRef.balance
}