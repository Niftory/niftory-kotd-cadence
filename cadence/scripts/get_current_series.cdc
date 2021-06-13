import KOTD from "../contracts/KOTD.cdc"

// This script reads the current Series from the KOTD contract and 
// returns that number to the caller

// Returns: KOTD.Series
// The Current Series struct in the KOTD contract

pub fun main(): KOTD.CurrSeriesData {
    let currSeries = KOTD.CurrSeriesData()
    return currSeries
}