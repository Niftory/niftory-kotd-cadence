import KOTD from 0x9f3e19cda04154fc

// This script returns an array of the play IDs that are
// in the specified set

// Parameters:
//
// setID: The unique ID for the set whose data needs to be read

// Returns: [UInt32]
// Array of play IDs in specified set

pub fun main(setID: UInt32): [UInt32] {

    let plays = KOTD.getPlaysInSet(setID: setID)!

    return plays
}