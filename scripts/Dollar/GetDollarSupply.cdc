import Dollar from "../../contracts/Dollar.cdc"

// This script returns the total amount of Dollar currently in existence.

pub fun main(): UFix64 {

    let supply = Dollar.totalSupply

    log(supply)

    return supply
}