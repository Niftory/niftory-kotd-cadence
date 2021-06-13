import KOTD from "../../contracts/KOTD.cdc"

// This transaction creates a new Collectible Item struct 
// and stores it in the KOTD smart contract

// Parameters:
//
// metadata: A dictionary of all the Collectible metadata associated

transaction(metaDataTitle: String, featuredArtists: [String]) {

    // Local variable for the topshot Admin object
    let adminRef: &KOTD.Admin
    let currCollectibleItemID: UInt32
    let metadata: {String: String}

    prepare(acct: AuthAccount) {

        // borrow a reference to the admin resource
        self.currCollectibleItemID = KOTD.nextCollectibleItemID;
        self.adminRef = acct.borrow<&KOTD.Admin>(from: /storage/KOTDAdmin003)
            ?? panic("No admin resource in storage")
        self.metadata = {
            "title": metaDataTitle
        }
    }

    execute {
       // Create a play with the specified metadata
        self.adminRef.createCollectibleItem(metadata: self.metadata, featuredArtists: featuredArtists)
    }

    post {
        
        KOTD.getCollectibleItemMetaData(collectibleItemID: self.currCollectibleItemID) != nil:
            "collectibleItemID doesnt exist"
    }
}