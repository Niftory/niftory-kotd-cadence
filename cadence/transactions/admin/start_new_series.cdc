import KOTD from "../../contracts/KOTD.cdc"

// This transaction is for an Admin to start a new Top Shot series

transaction (name: String?, identityURL: String?) {

    // Local variable for the topshot Admin object
    let adminRef: &KOTD.Admin
    let currentSeriesID: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&KOTD.Admin>(from: KOTD.AdminStoragePath)
            ?? panic("No admin resource in storage")

        self.currentSeriesID = KOTD.currentSeriesID
    }

    execute {
        
        // Increment the series number
        self.adminRef.startNewSeries(name: name, identityURL: identityURL)
    }
}