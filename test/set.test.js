import path from "path";
import { String as FlowString, UInt32, UInt64, Address } from "@onflow/types";
import { init, getAccountAddress, getTransactionCode, sendTransaction, getScriptCode, executeScript } from "flow-js-testing/dist";
import config from "../config.js"

const basePath = path.resolve(__dirname, "../cadence");

beforeAll(() => {
  init(basePath);
});

let setName = "Test Set 001"
let setId = ''
let collectibleItemId = ''
let collectibleTitle = 'New collectible'
let collectibleId = ''
let recipientAddress = ''

test("Create Set", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const create_set = await getTransactionCode({name: "admin/create_set", addressMap}) 
    const signers = [config["0xAdmin"]]
    const args = [[setName, FlowString]]

    try {
        const txResult = await sendTransaction({ code: create_set, args, signers });
        setId = txResult.events[0].data.setID
        expect(txResult.status).toEqual(4)
    } catch (e) {
        console.log(e);
    }
});

test("Get Set", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const get_set_name = await getScriptCode({name: "get_set_name", addressMap})
    const args = [[setId, UInt32]]

    try {
        const res = await executeScript({ code: get_set_name, args });
        expect(res).toEqual(setName)
        //console.log(res);
    } catch (e) {
        console.log(e);
    }
});

test("Get Current Series", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const get_current_series = await getScriptCode({name: "get_current_series", addressMap})
    const args = []

    try {
        const res = await executeScript({ code: get_current_series, args });
        expect(res.seriesID).toEqual(0)
        console.log(res);
    } catch (e) {
        console.log(e);
    }
});

test("Create collectible item", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const create_collectibe_item = await getTransactionCode({name: "admin/create_collectible_item", addressMap}) 
    const signers = [config["0xAdmin"]]
    const args = [[collectibleTitle, FlowString]]

    try {
        const txResult = await sendTransaction({ code: create_collectibe_item, args, signers });
        collectibleItemId = txResult.events[0].data.id
        expect(txResult.status).toEqual(4)
    } catch (e) {
        console.log(e);
    }
});

test("Get collectible item meta data", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const get_collectible_item_metadata = await getScriptCode({name: "get_collectible_item_metadata", addressMap})
    const signers = [config["0xAdmin"]]
    const args = [[collectibleItemId, UInt32]]

    try {
        const res = await executeScript({ code: get_collectible_item_metadata, args, signers });
        expect(res.title).toEqual(collectibleTitle)
    } catch (e) {
        console.log(e);
    }
});

test("Add collectible item to set", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const add_collectible_item_to_set = await getTransactionCode({name: "admin/add_collectible_item_to_set", addressMap}) 
    const signers = [config["0xAdmin"]]
    const args = [[setId, UInt32], [collectibleItemId, UInt32]]

    try {
        const txResult = await sendTransaction({ code: add_collectible_item_to_set, args, signers });
        expect(txResult.status).toEqual(4)
    } catch (e) {
        console.log(e);
    }
});

test("Get collectible items in a set", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const get_collectible_items_in_set = await getScriptCode({name: "get_collectible_items_in_set", addressMap}) 
    const signers = [config["0xAdmin"]]
    const args = [[setId, UInt32]]

    try {
        const res = await executeScript({ code: get_collectible_items_in_set, args, signers });
        //expect(txResult.status).toEqual(4) todo update this test
    } catch (e) {
        console.log(e);
    }
});

test("Mint collectible to set", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const mint_collectible = await getTransactionCode({name: "admin/mint_collectible", addressMap}) 
    const signers = [config["0xAdmin"]]
    const args = [[setId, UInt32], [collectibleItemId, UInt32], [config["0xAdmin"] , Address]]

    try {
        const txResult = await sendTransaction({ code: mint_collectible, args, signers });
        expect(txResult.status).toEqual(4)
        console.log("Minted: " + "{ ID: " + txResult.events[0].data.collectibleID + ", Serial: " + txResult.events[0].data.serialNumber
            + ", Collectible Item ID: " + txResult.events[0].data.collectibleItemID
            + ", Set ID: " + txResult.events[0].data.setID + "}")        
        
        collectibleId = txResult.events[0].data.collectibleID
    } catch (e) {
        console.log(e);
    }
});

test("Mint collectible in bulk", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const mint_collectibles_bulk = await getTransactionCode({name: "admin/mint_collectibles_bulk", addressMap}) 
    const signers = [config["0xAdmin"]]
    const args = [[setId, UInt32], [collectibleItemId, UInt32], [5, UInt64], [ config["0xAdmin"] , Address]]

    try {
        const txResult = await sendTransaction({ code: mint_collectibles_bulk, args, signers });
        expect(txResult.status).toEqual(4)
        for (var i = 0; i < txResult.events.length; i++) {
            if (txResult.events[i].type.includes("KOTD.CollectibleMinted")) {
                console.log("Minted: " + "{ ID: " + txResult.events[i].data.collectibleID + ", Serial: " + txResult.events[i].data.serialNumber
                    + ", Collectible Item ID: " + txResult.events[i].data.collectibleItemID
                    + ", Set ID: " + txResult.events[i].data.setID + "}")
            }
        }
    } catch (e) {
        console.log(e);
    }
});

test("Create recipient account", async () => {
    recipientAddress = await getAccountAddress("Alice");
    console.log("recipientAddress account created with address: " + recipientAddress);
});


test("Set up account", async () => {
    const addressMap = {NonFungibleToken: config["0xAdmin"], KOTD: config["0xAdmin"]};
    const setup_account = await getTransactionCode({name: "admin/setup_account", addressMap}) 
    const signers = [recipientAddress]
    const args = []

    try {
        const txResult = await sendTransaction({ code: setup_account, args, signers });
        expect(txResult.status).toEqual(4)
        console.log(txResult)
    } catch (e) {
        console.log(e);
    }
});

test("Transfer collectible to user", async () => {
    const addressMap = {NonFungibleToken: config["0xAdmin"], KOTD: config["0xAdmin"]};
    const transfer_collectible_to_user = await getTransactionCode({name: "admin/transfer_collectible_to_user", addressMap}) 
    const signers = [config["0xAdmin"]]
    const withdrawId = collectibleId
    const recipient = recipientAddress
    const args = [[recipient , Address], [withdrawId, UInt64]]
    console.log(args)

    try {
        const txResult = await sendTransaction({ code: transfer_collectible_to_user, args, signers });
        expect(txResult.status).toEqual(4)
        console.log(txResult)
        for (var i = 0; i < txResult.events.length; i++) {
            if (txResult.events[i].type.includes("KOTD.Deposit")) {
                console.log("Deposited: " + "[ID: " + txResult.events[i].data.id + "] to Address: " + txResult.events[i].data.to)
            }
        }
    } catch (e) {
        console.log(e);
    }
});