#!/bin/bash

#NOTE: DONT CTRL+C OR CLEANUP WONT OCCUR
#      ENSURE PORTS 5001,5002 ARE UNUSED

#initial build
go build -ldflags '-X main.BuildID=1' -o my_app current/main.go
echo "BUILT APP (1)"
#run!
echo "RUNNING APP"
./my_app &
APPPID=$!

sleep 1
curl localhost:5001
sleep 1
curl localhost:5001
sleep 1
#request during an update
curl localhost:5001?d=5s &

rm current
ln -s ./symbolic_2 current
go build -ldflags '-X main.BuildID=2' -o my_app_next current/main.go
echo "BUILT APP (2)"

sleep 2
curl localhost:5001
sleep 1
curl localhost:5001
sleep 1
#request during an update
curl localhost:5001?d=5s &

rm current
ln -s ./symbolic_1 current
go build -ldflags '-X main.BuildID=3' -o my_app_next current/main.go
echo "BUILT APP (3)"

sleep 2
curl localhost:5001
sleep 1
curl localhost:5001
sleep 1
curl localhost:5001

sleep 1

#end demo - cleanup
kill $APPPID
rm my_app* 2> /dev/null
rm current
ln -s ./symbolic_1 current

# Expected output (hashes will vary across OS/arch/go-versions):
# BUILT APP (1)
# RUNNING APP
# app#1 (d8eae3bf7fbccd2f5ac168b10ea24c19720186ea) listening...
# app#1 (d8eae3bf7fbccd2f5ac168b10ea24c19720186ea) symbolic_1 says hello
# app#1 (d8eae3bf7fbccd2f5ac168b10ea24c19720186ea) symbolic_1 says hello
# BUILT APP (2)
# app#2 (10455c90e3cb056d9013d48535dd3ece400e84a6) listening...
# app#2 (10455c90e3cb056d9013d48535dd3ece400e84a6) symbolic_2 says hello
# app#2 (10455c90e3cb056d9013d48535dd3ece400e84a6) symbolic_2 says hello
# app#1 (d8eae3bf7fbccd2f5ac168b10ea24c19720186ea) symbolic_1 says hello
# app#1 (d8eae3bf7fbccd2f5ac168b10ea24c19720186ea) symbolic_1 exiting...
# BUILT APP (3)
# app#3 (6d578db20a36c271ada010645c830c449945303b) listening...
# app#3 (6d578db20a36c271ada010645c830c449945303b) symbolic_1 says hello
# app#3 (6d578db20a36c271ada010645c830c449945303b) symbolic_1 says hello
# app#3 (6d578db20a36c271ada010645c830c449945303b) symbolic_1 says hello
# app#2 (10455c90e3cb056d9013d48535dd3ece400e84a6) symbolic_2 says hello
# app#2 (10455c90e3cb056d9013d48535dd3ece400e84a6) symbolic_2 exiting...
