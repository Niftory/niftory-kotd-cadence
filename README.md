# niftory-cadence

## Getting Started: General
| :exclamation:  This project last tested on Flow CLI v0.20.2. |
|--------------------------------------------------------------|

1. Install the Flow CLI:

    ```
    brew install flow-cli
    ```

## Getting Started: Working on Tests
| :exclamation: Cadence tests are expected to run against the local emulator. |
|-----------------------------------------------------------------------------|

1. Navigate to the lib/go/test path.
2. Set up your testing flow.json file, per the example.flow.json in the lib/go/test directory.
3. Start a shell window in this directory and run:

    ```
    flow emulator -v
    ```
4. Open another shell window and run the following command to deploy your contracts:
    ```
    flow project deploy --network=emulator
    ```
5. Run your tests

    ```
    npm run test
    ```

#### In order to update a deployed contract, restart your emulator. You _can_ try the following command:

    flow project deploy --network=emulator --update
   
| :zap: These next areas are focused on testnet, not the local emulator. |
|-----------------------------------------------------------------------------|
## Getting Started: General Cadence Testnet Operations

1. Generate a key pair with the Flow CLI:
    ```
    flow keys generate
    ```

    | :zap: Make sure to save these keys in a safe place, you'll need them later. |
    |-----------------------------------------------------------------------------|

2. Go to the Flow Testnet Faucet to create a new testnet account. Use the public key from the previous step.

4. Set up your flow.json file, per the example.flow.json in the root directory.

You're now setup to run any desired commands against testnet.

## Common Commands
| :bulb: Contracts are already deployed to testnet - you'll generally only need to run scripts and transactions. |
|---------------------------------------------------------------------------------------------------------------|

#### Deploy contract 
    
    flow project deploy --network=testnet

#### Update deployed contract
    flow project deploy --network=testnet --update

| :bulb: Only certain changes to a contract can be deployed via --update. |
|-------------------------------------------------------------------------|

##### Create Set
    flow transactions send ./cadence/transactions/admin/create_set.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args-json '[{"type": "String","value": "Test Set 001"}]'

##### Get Set Name
    flow scripts execute ./cadence/scripts/get_set_name.cdc --host access.testnet.nodes.onflow.org:9000 --args-json '[{"type": "UInt32","value": "1"}]'

##### Create Collectible Item (Content) - Not Working
    flow transactions send ./cadence/transactions/admin/create_collectible_item.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args-json '[{"type": "Dictionary","value": [{"key": {"type": "String", "value": "Title"}, "value": { "type": "String", "value": "Test Moment 002" },}]}]'

##### Create Collectible Item (Content)
    flow transactions send ./cadence/transactions/admin/create_collectible_item.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args-json '[{"type": "String","value": "Test Moment 002"}]'

##### Mint a Collectible NFT
    flow transactions send ./cadence/transactions/admin/mint_collectible.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args-json '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}]'

##### Add a Collectible Item to a Set
    flow transactions send ./cadence/transactions/admin/add_collectible_item_to_set.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args-json '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}]'

##### Batch Mint Collectible NFTs
    flow transactions send ./cadence/transactions/admin/mint_collectibles_bulk.cdc --signer testnet-account --host access.testnet.nodes.onflow.org:9000 --results --args-json '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}, {"type": "UInt64","value": "10"}]'

##### Get Collectible IDs in a Collection
    flow scripts execute ./cadence/scripts/get_collection_collectible_ids.cdc --host access.testnet.nodes.onflow.org:9000 --args-json '[{"type": "Address","value": "0x9f3e19cda04154fc"}]'

##### Get Metadata for a Given Collectible Item
     flow scripts execute ./cadence/scripts/get_collectible_item_metadata.cdc --host access.testnet.nodes.onflow.org:9000 --args-json '[{"type": "UInt32","value": "1"}]'

##### Get Serial Number for a Collectible
    flow scripts execute ./cadence/scripts/get_collectible_serial_number.cdc --host access.testnet.nodes.onflow.org:9000 --args-json '[{"type": "Address","value": "0x9f3e19cda04154fc"}, {"type": "UInt64","value": "8"}]'

##### Get the Edition Size for an Edition (Set + CollectibleItem)
    flow scripts execute ./cadence/scripts/get_edition_size.cdc --host access.testnet.nodes.onflow.org:9000 --args-json '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}]'
