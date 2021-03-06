# niftory-kotd-cadence

This repo contains the smart contracts, supporting transactions and scripts, and test suite for the KOTD collectible experience, built on Flow.

The collectible structure is very similar to NBA Top Shot (and most card based collectibles), where collectibles will be minted in varying size runs, and belong to different sets and series over time.  Some improvements and changes have been made to the Top Shot contract, including:

 * Nomenclature changes (e.g. 'Play' -> 'CollectibleItem')
 * Small quality of life improvements, like named paths
 * Data access improvements based off of Josh Hannan's "What I’ve learned since Top Shot" Cadence blogs
 * Additional contract defined metadata at the Series, Set, and CollectibleItem level
 * Functionality conveniences, such as closing all open sets & editions when starting a new Series

The official flow-js-testing library has been used for the creation of the test suite.

Much thanks to all the Dapper resouces and Discord help used in the adaptation of this contract!

| :exclamation:  This project last tested on Flow CLI v0.21.0 |
|--------------------------------------------------------------|

## Running the tests

To run the tests, yarn and the Flow CLI must be installed.

    
    npm install --global yarn
    
    brew install flow-cli
    


Once installed, from the root of the project:

1. Install all dependencies:

    ```
    yarn install
    ```
    
2. Set up your flow.json and .env, following the template from example.flow.json and env.example.

3. Make the test shell script executable:

    ```
    chmod +x tests.sh
    ```
    
4. Run the 'test' shell script; this starts the flow emulator, deploys contracts, runs all tests, then cleans up the emulator:
    
    ```
    ./tests.sh
    ```

## Getting started with Testnet

1. Generate a key pair with the Flow CLI:
    ```
    flow keys generate
    ```

    | :zap: Make sure to save these keys in a safe place, you'll need them later. |
    |-----------------------------------------------------------------------------|

2. Go to the Flow Testnet Faucet to create a new testnet account. Use the public key from the previous step.

4. Set up your flow.json file, per the example.flow.json in the root directory.

You're now setup to run any desired commands against testnet.

## Common commands
| :bulb: Contracts are already deployed to testnet at 0x9f3e19cda04154fc - you'll generally only need to run scripts and transactions. |
|---------------------------------------------------------------------------------------------------------------|

##### Deploy contract 
    
    flow project deploy --network=testnet

##### Update deployed contract
    flow project deploy --network=testnet --update

| :bulb: Only certain changes to a contract can be deployed via --update. |
|-------------------------------------------------------------------------|

##### Remove deployed contract
    flow accounts remove-contract KOTD --network=testnet --signer=testnet-account

##### Create Set
    flow transactions send ./cadence/transactions/admin/create_set.cdc --signer testnet-account --network=testnet --args-json '[{"type": "String","value": "Test Set 001"}]'

##### Get Set Name
    flow scripts execute ./cadence/scripts/get_set_name.cdc --network=testnet --args-json '[{"type": "UInt32","value": "1"}]'

##### Create Collectible Item (Content)
    flow transactions send ./cadence/transactions/admin/create_collectible_item.cdc --signer testnet-account --network=testnet --args-json '[{"type": "String","value": "Test Moment 002"}]'

##### Mint a Collectible NFT
    flow transactions send ./cadence/transactions/admin/mint_collectible.cdc --signer testnet-account --network=testnet --args-json '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "1"}, {"type": "Address","value": "0x9f3e19cda04154fc"}]'

##### Add a Collectible Item to a Set
    flow transactions send ./cadence/transactions/admin/add_collectible_item_to_set.cdc --signer testnet-account --network=testnet --args-json '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}]'

##### Batch mint Collectible NFTs
    flow transactions send ./cadence/transactions/admin/mint_collectibles_bulk.cdc --signer testnet-account --network=testnet --args-json '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}, {"type": "UInt64","value": "10"}]'

##### Get Collectible IDs in a Collection
    flow scripts execute ./cadence/scripts/get_collection_collectible_ids.cdc --network=testnet --args-json '[{"type": "Address","value": "0x9f3e19cda04154fc"}]'

##### Get metadata for a given Collectible Item
     flow scripts execute ./cadence/scripts/get_collectible_item_metadata.cdc --network=testnet --args-json '[{"type": "UInt32","value": "1"}]'

##### Get Serial Number for a Collectible
    flow scripts execute ./cadence/scripts/get_collectible_serial_number.cdc --network=testnet --args-json '[{"type": "Address","value": "0x9f3e19cda04154fc"}, {"type": "UInt64","value": "8"}]'

##### Get the Edition Size for an Edition (Set + CollectibleItem)
    flow scripts execute ./cadence/scripts/get_edition_size.cdc --network=testnet --args-json '[{"type": "UInt32","value": "1"}, {"type": "UInt32","value": "2"}]'
