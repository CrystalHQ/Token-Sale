pragma solidity ^0.4.0;

/* Forked From https://github.com/FirstBloodio/token

This is the VerityClear token and token sale contract. This will handle all backend aspects of our token sale.

Security review should be at minimum performed by reputable third parties
per best practices enumerated here: https://github.com/ConsenSys/smart-contract-best-practices
*/

//@todo - Distribution of funds per Augur style auction:
    //Instead of setting a price per VerityClear minting tokens when purchased,
    // we want to allocate the total VerityClear (TOTALQTY) and let the market price the VerityClear
    // see: How does the live-action model work? http://augur.strikingly.com/blog/the-augur-crowdsale
    // basically each buyer buys some fraction of the TOKEN_SUPPLY_CAP number of tokens which
    // will be calculated by (PURCHASER_AMT / TOTALFUNDED) * TOKEN_SUPPLY_CAP
    // Buy will be for quantity to equal purchased value at final valuation, not X qty.
    // The buyer will buy a fraction of total tokens
    // based on the amount they purchased as the denominator under the total fund at closing.
    // So we only need to keep track of how much was sent and TOKEN_SUPPLY_CAP/BUYER_AMT will give us the senders percent of tokens.
    // This calculation need only be performd upon final ditsribution at the end of ICO.
    // If we want to update a web page or other UI during the sale we can calculate using
    // metrics pulled from events or maybe allow the contract to be queried for totalfund / number purchasers

//@todo - How do we deal with founder donations instead of founder allocations. Do we need to start from scratch?
  // under the auction model above we allow a percentage to be donated to the founders. We just further split the pie
  // by the founder percent. Default gift to founders can be overridden during purchase.
  // Default to some sane amount like 10% (needs research)
  // One way to do this is to issue to founders the matching funds in units of ether,
  // but do not use real ether but 'gift ether'. Then the market valuation will be inflated, diluting the pie, and
  // issuing tokens to founders at the close based on the 'gift ether'.

//@todo - How do we deal with timed release for founder dontations.
    // time lock that will release based on block number (estimated at x sec per block)
    // input to contract function will be founder address. Test will be for vesting block number.
    // after block number is reached funds can be disbursed to the addresses, calulated by founder percents

//@todo - How do we deal with pre-allocations for advisors,etc.
    // pre-allocate a percentage of the TOKEN_SUPPLY_CAP by issuing 'fake ether'

//@todo - How do we deal with time release for pre-allocations
    // same as above for founders






/**
 * VerityClear token sale contract.
 *
 * Original firstblood security criteria evaluated against
 * http://ethereum.stackexchange.com/questions/8551/methodological-security-review-of-a-smart-contract
 *
 *
 */
contract VerityClearToken is StandardToken, SafeMath {

    string public name = "Verity Clear Token";
    string public symbol = "VRC";
    uint public decimals = 18;
    uint public startBlock; //token sale start block (set in constructor)
    uint public endBlock; //token sale end block (set in constructor)

    // Initial owner Multisig address (set in constructor)
    // All deposited ETH will be instantly forwarded to this address.
    // Address is a multisig contract such as ds-multisig https://github.com/nexusdev/ds-multisig.
    address public ownerMultisig = 0x0;

    // signer address (for crowdsale agreement)
    // see function() {} for comments
    address public signer = 0x0;

/* Constants*/
    uint public maxMarketCapInEther = 10 * 10**5; // 1,000,000 max ether we will take in before ending sale early, aprox 12M USD
    uint public fixedTokenSupply = 10 * 10**7; //100,000,000 this is the total token supply created on contract deployment.
    uint public transferLockup = 370285; //transfers are locked for this many blocks after endBlock (assuming 14 second blocks, this is 2 months)
    uint public founderLockup = 2252571; //founder allocation cannot be created until this many blocks after endBlock (assuming 14 second blocks, this is 1 year)
    bool public founderDistributed = false; //this will change to true when the founder tokens are distributed
    bool public buyersDistributed = false; //this will change to true when the buyers tokens are distributed
    uint public totalFunded = 0; //this will keep track of the Ether raised during the token sale
    uint public totalFounderPool = 0; //matching funds to founders
    bool public halted = false; //the ownerMultisig address can set this to true to halt the token sale due to emergency


    //@todo  ok to store percent in uint? how do we get precision we need?
    mapping(address => uint) founderPercents;

    event BuyEvent(address indexed sender, uint eth, uint fbt);
    //@todo dead code, Withdraw event unused ?
    event Withdraw(address indexed sender, address to, uint eth);
    event DistributeFounderTokensEvent(address indexed sender);
    event DistributeBuyersTokensEvent(address indexed sender);
    event SetFounderDistributionPercentEvent(address indexed sender);

    //when testing a single account instead of a multisig will do
    function VerityClearToken(address foundationInputMultiSig, address signerInput, uint startBlockInput, uint endBlockInput) {
        ownerMultisig = foundationInputMultiSig;
        signer = signerInput;
        startBlock = startBlockInput;
        endBlock = endBlockInput;
        totalSupply = fixedTokenSupply;
    }

    /**
     * Security review
     *
     * - Integer overflow: does not apply, blocknumber can't grow that high
     * - Division is the last operation and constant, should not cause issues
     * - Price function plotted https://github.com/firstbloodio/token/issues/2
     */
    function discount() constant returns(uint) {
        //@todo - Figure out if we want power hour.
        if (block.number>=startBlock && block.number<startBlock+250) return 170; //power hour
        if (block.number<startBlock || block.number>endBlock) return 100; //default price
        return 100 + 4*(endBlock - block.number)/(endBlock - startBlock + 1)*67/4; //token sale price
    }

    // discount() exposed for unit tests
    function testDiscount(uint blockNumber) constant returns(uint) {
        if (blockNumber>=startBlock && blockNumber<startBlock+250) return 170; //power hour
        if (blockNumber<startBlock || blockNumber>endBlock) return 100; //default price
        return 100 + 4*(endBlock - blockNumber)/(endBlock - startBlock + 1)*67/4; //token sale price
    }

    // buy entry point
    function buy(uint8 v, bytes32 r, bytes32 s) {
        buyRecipient(msg.sender, v, r, s);
    }

    /**
     * Main token buy function.
     *
     * buy for the sender itself or buy on the behalf of somebody else (third party address).
     *
     * Security review
     *
     * - Integer math: ok - using SafeMath
     *
     * - halt flag added - ok
     *
     * Applicable tests:
     *
     * - Test halting, buying, and failing
     * - Test buying on behalf of a recipient
     * - Test buy
     * - Test unhalting, buying, and succeeding
     * - Test buying after the sale ends
     *
     */
    function buyRecipient(address recipient, uint8 v, bytes32 r, bytes32 s) {
        bytes32 hash = sha256(msg.sender);
        if (ecrecover(hash,v,r,s) != signer) throw;
        if (block.number<startBlock
          || block.number>endBlock
          || safeAdd(totalFunded,msg.value)>maxMarketCapInEther
          || halted) throw;

        //under our new model, this will happen upon distribution, at end of ICO
        private uint tokens = safeMul(msg.value, discount());
        balances[recipient] = safeAdd(balances[recipient], tokens);

        //totalSupply will be fixed in our auction style buying
        //was: totalSupply = safeAdd(totalSupply, tokens);
        // for now we just track eth received until final distribution of tokens

        //this will be total funded
        totalFunded = safeAdd(totalFunded, msg.value);

        // TODO: Is there a pitfall of forwarding message value like this
        // TODO: Different address for founder deposits and founder operations (halt, unhalt)
        // as founder opeations might be easier to perform from normal geth account
        if (!ownerMultisig.send.value(msg.value)()) throw; //immediately send Ether to founder address
        BuyEvent(recipient, msg.value, tokens);
    }

    /**
     * Distribute token balance for all buyers.
     * Performed once at end of ICO / Auction
     * distributeFounderTokens() must be calld first.
     *
     *  Security not reviewed
     *   todo - review: Integer divisions are always rounded down
     *
     *
     * Applicable tests:
     *    boundries for math / division. What is precision limit ?
     *
     */
    function distributeBuyersTokens() {
        if (msg.sender!=ownerMultisig) throw;
        if (block.number <= endBlock + founderLockup) throw;
        //if (fundedAmt < MINIMUM_FUND_CAP) throw;
        if (buyersDistributed) throw;
        if (!founderDistributed) throw;

        // foreach buyer
        // balances[buyer] = TOKEN_SUPPLY_CAP * ( funded[buyer] / safeAdd(totalFunded + totalGifted) );

        // old example code...
        // balances[founder] = safeAdd(balances[founder], presaleTokenSupply * founderAllocation / (1 ether));
        // totalSupply = safeAdd(totalSupply, presaleTokenSupply * founderAllocation / (1 ether));
        buyersDistributed = true;
        DistributeBuyersTokensEvent(msg.sender);
    }

    function setFounderDistributionPercent(address founder, uint percent) {
        if(msg.sender!=ownerMultisig) throw;
        if(block.number<startBlock) throw;
        if(percent + percentOthers > 100) throw;
        founderPercents[founder] = percent;
        percentOthers = percentOthers + percent;
        SetFounderDistributionPercentEvent(msg.sender);
    }


    function distributeFounderTokens() {
        private uint percentTotal;
        if (msg.sender!=ownerMultisig) throw;
        if (block.number <= endBlock + founderLockup) throw;
        //if (fundedAmt < MINIMUM_FUND_CAP) throw;
        if (!buyersDistributed) throw;
        if (!founderDistributed) throw;
        // foreach founder
        // percentTotal = percentTotal + founderPercents[founder];
        // if (percentTotal != 100) throw;

        // foreach founder
        // real founderPercent = founderPercents[founder]/100;
        // balances[founder] = TOKEN_SUPPLY_CAP * ( (totalGifted * founderPercent) / safeAdd(totalFunded + totalGifted) );

        // old example code...
        // balances[founder] = safeAdd(balances[founder], presaleTokenSupply * founderAllocation / (1 ether));
        // totalSupply = safeAdd(totalSupply, presaleTokenSupply * founderAllocation / (1 ether));
        founderDistributed = true;
        DistributeFounderTokensEvent(msg.sender);
    }

/*Contract Escape Hatch*/
    /**
     * Emergency Stop ICO.
     *
     *  Applicable tests:
     *
     * - Test unhalting, buying, and succeeding
     */
    function halt() {
        if (msg.sender!=ownerMultisig) throw;
        halted = true;
    }

    function unhalt() {
        if (msg.sender!=ownerMultisig) throw;
        halted = false;
    }

    /**
     * Change founder address (where ICO ETH is being forwarded).
     *
     * Applicable tests:
     *
     * - Test founder change by hacker
     * - Test founder change
     * - Test founder token allocation twice
     */
    function changeOwnerMultisig(address newMultisigAddress) {
        if (msg.sender!=ownerMultisig) throw;
        ownerMultisig = newMultisigAddress;
    }

    /**
     * ERC 20 Standard Token interface transfer function
     *
     * Prevent transfers until freeze period is over.
     *
     * Applicable tests:
     *
     * - Test restricted early transfer
     * - Test transfer after restricted period
     */
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (block.number <= endBlock + transferLockup && msg.sender!=ownerMultisig) throw;
        return super.transfer(_to, _value);
    }
    /**
     * ERC 20 Standard Token interface transfer function
     *
     * Prevent transfers until freeze period is over.
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (block.number <= endBlock + transferLockup && msg.sender!=ownerMultisig) throw;
        return super.transferFrom(_from, _to, _value);
    }

/* Check for signing agreement*/
    /**
     * Do not allow direct deposits.
     *
     * All token sale depositors must have read the legal agreement.
     * This is confirmed by having them signing the terms of service on the website.
     * They give their token sale Ethereum source address on the website.
     * Website signs this address using token sale private key (different from founders key).
     * buy() takes this signature as input and rejects all deposits that do not have
     * signature you receive after reading terms of service.
     *
     */
    function() {
        throw;
    }
}
