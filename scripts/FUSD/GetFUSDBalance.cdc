import FungibleToken from 0x9a0766d93b6608b7
import FUSD from 0xe223d8a629e49c68

pub fun main(): UFix64 {
    let account = Address(0x9f3e19cda04154fc)

    let vaultRef = getAccount(account)
        .getCapability(/public/fusdBalance)!
        .borrow<&FUSD.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance capability")

  return vaultRef.balance
}