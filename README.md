# niftory-cadence

    flow project deploy --network=testnet --update
    
    flow transactions send --code=./transactions/admin/create_set.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args '[{"type": "String","value": "Test Set 001"}]'

    flow scripts execute --code=./scripts/get_set_name.cdc --host access.testnet.nodes.onflow.org:9000 --args '[{"type": "UInt32","value": "1"}]'

    flow transactions send --code=./transactions/admin/create_collectible_item.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args '[{"type": "Dictionary","value": [{"key": {"type": "String", "value": "Title"}, "value": { "type": "String", "value": "Test Moment 002" },}]}]'

    flow transactions send --code=./transactions/admin/create_collectible_item.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args '[{"type": "String","value": "Test Moment 002"}]'

    flow transactions send --code=./transactions/admin/mint_collectible.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}]'

    flow transactions send --code=./transactions/admin/add_collectible_item_to_set.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}]'

    flow transactions send --code=./transactions/admin/mint_collectibles_bulk.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}, {"type": "UInt64","value": "10"}]'

    flow scripts execute --code=./scripts/get_collection_collectible_ids.cdc --host access.testnet.nodes.onflow.org:9000 --args '[{"type": "Address","value": "0x9f3e19cda04154fc"}]'

     flow scripts execute --code=./scripts/get_collectible_item_metadata.cdc --host access.testnet.nodes.onflow.org:9000 --args '[{"type": "UInt32","value": "1"}]'