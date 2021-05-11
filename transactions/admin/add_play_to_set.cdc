import KOTD from 0x9f3e19cda04154fc

// This transaction is how a Top Shot admin adds a created play to a set

// Parameters:
//
// setID: the ID of the set to which a created play is added
// momentID: the ID of the play being added

transaction(setID: UInt32, momentID: UInt32) {

    // Local variable for the topshot Admin object
    let adminRef: &KOTD.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&KOTD.Admin>(from: /storage/KOTDAdmin001)
            ?? panic("Could not borrow a reference to the Admin resource")
    }

    execute {
        
        // Borrow a reference to the set to be added to
        let setRef = self.adminRef.borrowSet(setID: setID)

        // Add the specified play ID
        setRef.addMoment(momentID: momentID)
    }

    post {

        KOTD.getMomentsInSet(setID: setID)!.contains(momentID): 
            "set does not contain momentID"
    }
}