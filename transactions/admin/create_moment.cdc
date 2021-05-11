import KOTD from 0x9f3e19cda04154fc

// This transaction creates a new play struct 
// and stores it in the Top Shot smart contract
// We currently stringify the metadata and insert it into the 
// transaction string, but want to use transaction arguments soon

// Parameters:
//
// metadata: A dictionary of all the play metadata associated

transaction(metaDataTitle: String) {

    // Local variable for the topshot Admin object
    let adminRef: &KOTD.Admin
    let currMomentID: UInt32
    let metadata: {String: String}

    prepare(acct: AuthAccount) {

        // borrow a reference to the admin resource
        self.currMomentID = KOTD.nextMomentID;
        self.adminRef = acct.borrow<&KOTD.Admin>(from: /storage/KOTDAdmin001)
            ?? panic("No admin resource in storage")
        self.metadata = {
            "title": metaDataTitle
        }
    }

    execute {
       // Create a play with the specified metadata
        self.adminRef.createMoment(metadata: self.metadata)
    }

    post {
        
        KOTD.getMomentMetaData(momentID: self.currMomentID) != nil:
            "momentID doesnt exist"
    }
}