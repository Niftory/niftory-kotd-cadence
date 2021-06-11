import KOTD from "../contracts/KOTD.cdc"

// This script reads the Series of the specified set and returns it

// Parameters:
//
// setID: The unique ID for the set whose data needs to be read

// Returns: KOTD.Series
// The Series struct

pub fun main(setID: UInt32): KOTD.Series {
    return KOTD.SetData(setID: setID).series
}