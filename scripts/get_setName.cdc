import KOTD from 0x9f3e19cda04154fc

// This script gets the setName of a set with specified setID

// Parameters:
//
// setID: The unique ID for the set whose data needs to be read

// Returns: String
// Name of set with specified setID

pub fun main(setID: UInt32): String {

    let name = KOTD.getSetName(setID: setID)
        ?? panic("Could not find the specified set")
        
    return name
}