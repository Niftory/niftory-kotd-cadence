import KOTD from "../contracts/KOTD.cdc"

// This script reads the current series from the KOTD contract and 
// returns that number to the caller

// Returns: KOTD.Series
// currentSeries field in TopShot contract

pub fun main(): KOTD.CurrSeriesData {
    let currSeries = KOTD.CurrSeriesData()
    return currSeries
}