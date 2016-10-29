# crowdfund
Crystal token sale contracts and site

$ cd fund
$ truffle test
=======


To get Mist to see geth it expects by default that the ipc path will be in /Users/foo/Library/Ethereum/geth.ipc

I use gethdev to make running geth simpler, but will still need to pass the default IPC path in for Mist to work.
https://github.com/amacneil/gethdev

gethdev --ipcpath /Users/kingdo/Library/Ethereum/geth.ipc

if you want to attach the geth console you may need to specify the ipc path if geth is not running against the standard Libraray/Ehtereum/geth.ipc   
(  like so: geth attach ipc:/tmp/geth/geth.ipc )
or if you ran with gethdev, use gethdev attach and it should find it using the settings in gethdev.js  .
which (on my Mac) is here: /usr/local/lib/node_modules/gethdev/gethdev.js

if Ether Wallet is not seeing any transactions processing,
you may need to start the miner from the geth console with miner.start() and miner.stop()
This will also mine ether into your coinbase account which you should see going up in your wallet.

You need to be running testrpc, or geth --rpc or some other Ethereum client with RPC enabled or you will get:
Error: Invalid JSON RPC response: "Error: connect ECONNREFUSED 127.0.0.1:8545\ suggests it is having trouble connecting to that

To run testrpc with repeatable accounts (deterministic) use the deterministic switch

To run Mist via the command line on a Mac:
http://osxdaily.com/2007/02/01/how-to-launch-gui-applications-from-the-terminal/
assuming it was installed on OSX by dragging into the app folder

open -a Mist --args --rpc http://localhost:8545

--args switch on the open command will pass the remaining args to the program being opened

Inside the Wallet.app/Contents/Frameworks/node/geth you find the geth binary.
Ideally you install it yourself using brew install ethereum and keep it updated with latest


Accounts:
Alice - Main (Etherbase) - 0xbDB1552Fa1810e12f08DE863eB318DfEB1839D1A
Bob - ??? 0x0e77Cd86a3C664E48e249CE7b1B01ee9B3a0c1f3
Charlie - ??? 0x813b39F4BA6d0A532519342ac42b4415629e7544
Alice & Bob multisig  0xB9Fdde52b9b8eA0c8e49E36CC8aF284EBA0A8C94
Drew  0x70748c1D5e97da23543C663324a712CC64421195
Elmer  0xA8A2010Dc5c8389e18Ec526183AdB7f95bC5550e
Fred  0x5691783492006951EdfA87458FbD139ee6db2429


foobar - 0xB9f00a57383E200fe86c28C68Bc3A8D51e16d37c
Alice & Drew  multisig 0x7D45ac36c20431aFd2ec631528C5B2C5f35Aa383
Alice & foobar multisig 0x112880897E39F188F73F6eD053af9eAf3019c6D2


If you manually start geth with the --datadir option, geth.exe will use your specified directory
for the blockchain data and the keystore information. You should use this when running against local geth miner/chain
or when switching between accounts and contracts for testing.
http://ethereum.stackexchange.com/questions/946/how-to-backup-mist-wallets/1981#1981

After geth.exe has started, start Ethereum-Wallet.exe and it will communicate with geth.exe which is using your specified directory.


https://github.com/ethereum/go-ethereum/wiki/Managing-your-accounts
It can be helpful to store commonly used functions to be recalled later. The loadScript function makes this very easy.
First, save the checkAllBalances() function definition to a file on your computer.
For example, /Users/username/gethload.js. Then load the file from the interactive console:

> loadScript("/Users/username/gethload.js")
true
The file will modify your JavaScript environment as if you has typed the commands manually. Feel free to experiment!

Another testing stategy is to fork morden testnet to your local testnet and continue to test locally.
All eth and contracts from Morden will be available.
Good for testing interop with other systems, or delivering a testnet to a client, etc.
You can do this with testrpc -f <morden url>`
When using metamask:
`testrpc -f $RPC_URL -i 898989898989` solves the problem of MM merging forked and original transaction histories
(`-i` sets a custom `networkId`)
>>>>>>> Stashed changes
