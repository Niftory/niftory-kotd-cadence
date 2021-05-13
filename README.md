# niftory-cadence

##### Deploy
    flow project deploy --network=testnet --update

##### Create Set
    flow transactions send --code=./transactions/admin/create_set.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args '[{"type": "String","value": "Test Set 001"}]'

##### Get Set Name
    flow scripts execute --code=./scripts/get_set_name.cdc --host access.testnet.nodes.onflow.org:9000 --args '[{"type": "UInt32","value": "1"}]'

##### Create Collectible Item (Content) - Not Working
    flow transactions send --code=./transactions/admin/create_collectible_item.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args '[{"type": "Dictionary","value": [{"key": {"type": "String", "value": "Title"}, "value": { "type": "String", "value": "Test Moment 002" },}]}]'

##### Create Collectible Item (Content)
    flow transactions send --code=./transactions/admin/create_collectible_item.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args '[{"type": "String","value": "Test Moment 002"}]'

##### Mint a Collectible NFT
    flow transactions send --code=./transactions/admin/mint_collectible.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}]'

##### Add a Collectible Item to a Set
    flow transactions send --code=./transactions/admin/add_collectible_item_to_set.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}]'

##### Batch Mint Collectible NFTs
    flow transactions send ./cadence/transactions/admin/mint_collectibles_bulk.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}, {"type": "UInt64","value": "10"}]'

##### Get Collectible IDs in a Collection
    flow scripts execute --code=./scripts/get_collection_collectible_ids.cdc --host access.testnet.nodes.onflow.org:9000 --args '[{"type": "Address","value": "0x9f3e19cda04154fc"}]'

##### Get Metadata for a Given Collectible Item
     flow scripts execute --code=./scripts/get_collectible_item_metadata.cdc --host access.testnet.nodes.onflow.org:9000 --args '[{"type": "UInt32","value": "1"}]'

##### Get Serial Number for a Collectible
    flow scripts execute --code=./scripts/get_collectible_serial_number.cdc --host access.testnet.nodes.onflow.org:9000 --args '[{"type": "Address","value": "0x9f3e19cda04154fc"}, {"type": "UInt64","value": "8"}]'

##### Get the Edition Size for an Edition (Set + CollectibleItem)
    flow scripts execute ./cadence/scripts/get_edition_size.cdc --host access.testnet.nodes.onflow.org:9000 --args-json '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}]'