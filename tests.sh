flow emulator >/dev/null &
sleep 2
flow project deploy --network emulator
yarn test
killall -9 flow emulator