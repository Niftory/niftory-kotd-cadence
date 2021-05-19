import path from "path";
import { String as FlowString, UInt32, UInt64, Address } from "@onflow/types";
import { init, getTransactionCode, sendTransaction, getScriptCode, executeScript } from "flow-js-testing/dist";
import config from "../config.js"

const basePath = path.resolve(__dirname, "../cadence");

beforeAll(() => {
  init(basePath);
});

let setId = ''
let collectibleId = ''

test("Create Set", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const create_set = await getTransactionCode({name: "admin/create_set", addressMap}) 
    const signers = [config["0xAdmin"]]
    const args = [["Test Set 001", FlowString]]

    try {
        const txResult = await sendTransaction({ code: create_set, args, signers });
        console.log({ txResult });
        setId = txResult.events[0].data.setID
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
        console.log({ res });
    } catch (e) {
        console.log(e);
    }
});

test("Create collectible item", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const create_collectibe_item = await getTransactionCode({name: "admin/create_collectible_item", addressMap}) 
    const signers = [config["0xAdmin"]]
    const args = [['New collectible', FlowString]]

    try {
        const res = await sendTransaction({ code: create_collectibe_item, args, signers });
        console.log({ res });
        collectibleId = res.events[0].data.id
        console.log(res.events[0].data.metadata)
    } catch (e) {
        console.log(e);
    }
});

test("Get collectible item meta data", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const get_collectible_item_metadata = await getScriptCode({name: "get_collectible_item_metadata", addressMap})
    const signers = [config["0xAdmin"]]
    const args = [[collectibleId, UInt32]]

    try {
        const res = await executeScript({ code: get_collectible_item_metadata, args, signers });
        console.log({ res });
    } catch (e) {
        console.log(e);
    }
});

test("Add collectible to set", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const add_collectible_to_set = await getTransactionCode({name: "admin/add_collectible_item_to_set", addressMap}) 
    const signers = [config["0xAdmin"]]
    const args = [[setId, UInt32], [collectibleId, UInt32]]

    try {
        const res = await sendTransaction({ code: add_collectible_to_set, args, signers });
        console.log({ res });
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
        console.log({ res });
    } catch (e) {
        console.log(e);
    }
});

test("Mint collectible to set", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const mint_collectible = await getTransactionCode({name: "admin/mint_collectible", addressMap}) 
    const signers = [config["0xAdmin"]]
    const args = [[setId, UInt32], [collectibleId, UInt32], [config["0xAdmin"] , Address]]

    try {
        const res = await sendTransaction({ code: mint_collectible, args, signers });
        console.log({ res });
    } catch (e) {
        console.log(e);
    }
});

test("Mint collectible in bulk", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const mint_collectibles_bulk = await getTransactionCode({name: "admin/mint_collectibles_bulk", addressMap}) 
    const signers = [config["0xAdmin"]]
    const args = [[setId, UInt32], [collectibleId, UInt32], [5, UInt64], [ config["0xAdmin"] , Address]]

    try {
        const res = await sendTransaction({ code: mint_collectibles_bulk, args, signers });
        console.log({ res });
    } catch (e) {
        console.log(e);
    }
});