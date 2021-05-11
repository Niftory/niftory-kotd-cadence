import KOTD from 0x9f3e19cda04154fc

// This transaction is for the admin to create a new set resource
// and store it in the top shot smart contract

// Parameters:
//
// setName: the name of a new Set to be created

transaction(setName: String) {
    
    // Local variable for the Admin object
    let adminRef: &KOTD.Admin
    let currSetID: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&KOTD.Admin>(from: /storage/KOTDAdmin001)
            ?? panic("Could not borrow a reference to the Admin resource")
        self.currSetID = KOTD.nextSetID;
    }

    execute {
        
        // Create a set with the specified name
        self.adminRef.createSet(name: setName)
    }

    post {
        
        KOTD.getSetName(setID: self.currSetID) == setName:
          "Could not find the specified set"
    }
}