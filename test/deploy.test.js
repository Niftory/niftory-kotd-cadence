const path = require("path");
const { init, getAccountAddress } = require("flow-js-testing/dist");
const config = require("../config.js");

init(path.resolve(__dirname, "../cadence"));

test("Create Accounts", async () => {
    const Alice = await getAccountAddress("Alice");
    const Bob = await getAccountAddress("Bob");
    const Charlie = await getAccountAddress("Charlie");
    const Dave = await getAccountAddress("Dave");

    console.log(
        "Four accounts were created with following addresses"
    );
    console.log("Alice:", Alice);
    console.log("Bob:", Bob);
    console.log("Charlie:", Charlie);
    console.log("Dave:", Dave);
});
