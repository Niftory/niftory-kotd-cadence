pub fun main(address: Address) : String {
    let account = getAccount(address)
    log(account.storageUsed)
    log(account.storageCapacity)

    let storageAmounts = "Storage Used: ".concat(account.storageUsed.toString()).concat(" / ").concat(account.storageCapacity.toString());

    return storageAmounts;
}