flow emulator >/dev/null &
flow project deploy --network emulator
yarn test
killall -9 flow emulator