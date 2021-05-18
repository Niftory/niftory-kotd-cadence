import path from "path";
import { String as FlowString, UInt32 } from "@onflow/types";
import { init, getTransactionCode, sendTransaction, getScriptCode, executeScript } from "flow-js-testing/dist";
import config from "../config.js"

const basePath = path.resolve(__dirname, "../cadence");

beforeAll(() => {
  init(basePath);
});

test("Create Set", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const create_set = await getTransactionCode({name: "admin/create_set", addressMap}) 
    const signers = [config["0xAdmin"]]
    const args = [["Test Set 001", FlowString]]

    try {
        const txResult = await sendTransaction({ code: create_set, args, signers });
        console.log({ txResult });
    } catch (e) {
        console.log(e);
    }
});

test("Get Set", async () => {
    const addressMap = {KOTD: config["0xAdmin"]};
    const get_set_name = await getScriptCode({name: "get_set_name", addressMap})
    const args = [[1, UInt32]]

    try {
        const res = await executeScript({ code: get_set_name, args });
        console.log({ res });
    } catch (e) {
        console.log(e);
    }
});
