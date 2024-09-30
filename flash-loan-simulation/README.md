Flashloan simulation with DEX arbitrage.
MockFlashLoanProvider simulates Equalizer Finance wti zero fee.
XToken is a generic ERC20 token having different values on different dexes.
Dex 1 & 2 are two different dexes (addresses) that holds a XToken of various values.
Argitrage will make the actual swap.

After contract initializations the contract will be supplied with XTokens.
The dexes will be assigned various XToken values per dex.
If dex1TokenPrice == dex2TokenPrice no arbitrage opportunity exists.
DexTokenPrices are compared to detrmine arbigtrage direction.
SwapAmount is determined to be the lowest balanceOf value of the Tokens per dex.
XToken -> MockFlashLoanProvider
Arbitrage flashloan <- MockFlashLoanProvider
Arbitrage buys from one Dex and seels to the other Dex. //<-- probable error here, Arbitrage deos not own XTokens borrowed. 



To run this simulation and see errors in RED.
In terminal 1: $ anvil
In terminal 2: flash-loan-simulation$ ./run.sh



Ignore warnigns from contract FlashloanReceiver.sol, not involved in this simulation!!! 
Will be used for step2.


