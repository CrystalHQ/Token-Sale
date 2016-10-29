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
    // lock in multisig contract owned by foundation that will release based on block number
    // input to contract will be founder address and founder percent and vesting block number
    // when block number is reached funds will be disbursed to the addresses recorded in hashmap

//@todo - How do we deal with pre-allocations for advisors,etc.
    // just pre-allocate a percentage of the TOKEN_SUPPLY_CAP

//@todo - How do we deal with time release for pre-allocations
    // same as above for founders

//@todo - consider a deadman switch that will return remaining eth funds to all token holders
  // in the event the foundation multisig is rendered useless.
  // This covers disaster scenarios like several signers being
  // unable to sign and administer the contract.
  // There should be a period of time that allows
  // for foundation-muiltisig to respond to the quorum vote from token holders
  // to stop return of funds if triggered.


/**
 * Overflow aware uint math functions.
 *
 * Inspired by https://github.com/MakerDAO/maker-otc/blob/master/contracts/simple_market.sol
 */
contract SafeMath {
  //internals

  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}

/**
 * ERC 20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 */
contract Token {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event TransferEvent(address indexed _from, address indexed _to, uint256 _value);
    event ApprovalEvent(address indexed _owner, address indexed _spender, uint256 _value);

}

/**
 * ERC 20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is Token {

    /**
     * Reviewed:
     * - Interger overflow = OK, checked
     */
    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        //if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            TransferEvent(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            TransferEvent(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        ApprovalEvent(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping(address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    uint256 public totalSupply;

}


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

    // Initial foundation multisig address (set in constructor)
    // All deposited ETH will be instantly forwarded to this address.
    // Address is a multisig wallet.
    address public foundation = 0x0;

    // signer address (for clickwrap agreement)
    // see function() {} for comments
    address public signer = 0x0;

/* Constants*/
    uint public etherCap = 500000 * 10**18; //max amount raised during token sale (5.5M USD worth of ether will be measured with market price at beginning of the token sale)
    uint public transferLockup = 370285; //transfers are locked for this many blocks after endBlock (assuming 14 second blocks, this is 2 months)
    uint public founderLockup = 2252571; //founder allocation cannot be created until this many blocks after endBlock (assuming 14 second blocks, this is 1 year)
    uint public founderAllocation = 10 * 10**16; //10% of token supply allocated post-token sale for the founder allocation
    bool public founderAllocated = false; //this will change to true when the founder fund is allocated
    bool public buyersAllocated = false; //this will change to true when the buyers tokens are allocated
    uint public fixedTokenSupply = 0; //this will keep track of the token supply created during the token sale
    uint public totalFunded = 0; //this will keep track of the Ether raised during the token sale
    bool public halted = false; //the foundation address can set this to true to halt the token sale due to emergency
    event BuyEvent(address indexed sender, uint eth, uint fbt);
    //@todo dead code, Withdraw event unused ?
    event Withdraw(address indexed sender, address to, uint eth);
    event AllocateFounderTokensEvent(address indexed sender);
    event AllocateBuyersTokensEvent(address indexed sender);
    event AllocateBountyAndEcosystemTokens(address indexed sender);

    //for testing a single account instead of a multisig will do
    function VerityClearToken(address foundationInputMultiSig, address signerInput, uint startBlockInput, uint endBlockInput) {
        foundation = foundationInputMultiSig;
        signer = signerInput;
        startBlock = startBlockInput;
        endBlock = endBlockInput;
    }

    /**
     * Security review
     *
     * - Integer overflow: does not apply, blocknumber can't grow that high
     * - Division is the last operation and constant, should not cause issues
     * - Price function plotted https://github.com/firstbloodio/token/issues/2
     */
    function price() constant returns(uint) {
        //@todo - Figure out if we want power hour.
        if (block.number>=startBlock && block.number<startBlock+250) return 170; //power hour
        if (block.number<startBlock || block.number>endBlock) return 100; //default price
        return 100 + 4*(endBlock - block.number)/(endBlock - startBlock + 1)*67/4; //token sale price
    }

    // price() exposed for unit tests
    function testPrice(uint blockNumber) constant returns(uint) {
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
          || safeAdd(totalFunded,msg.value)>etherCap
          || halted) throw;

        //under our new model, this will happen upon distribution, at end of ICO
        uint tokens = safeMul(msg.value, price());
        balances[recipient] = safeAdd(balances[recipient], tokens);

        //totalSupply will be fixed in our auction style buying
        //was: totalSupply = safeAdd(totalSupply, tokens);

        //this will be total funded
        totalFunded = safeAdd(totalFunded, msg.value);


        // TODO: Is there a pitfall of forwarding message value like this
        // TODO: Different address for founder deposits and founder operations (halt, unhalt)
        // as founder opeations might be easier to perform from normal geth account
        if (!founder.call.value(msg.value)()) throw; //immediately send Ether to founder address
        BuyEvent(recipient, msg.value, tokens);
    }

    /**
     * Distribute token balance for all buyers.
     * Performed once at end of ICO / Auction
     * allocateFounderTokens() must be calld first.
     *
     *  Security not reviewed
     *   todo - review: Integer divisions are always rounded down
     *
     *
     * Applicable tests:
     *    boundries for math / division. What is precision limit ?
     *
     */
    function allocateBuyersTokens() {
        if (msg.sender!=foundation) throw;
        if (block.number <= endBlock + founderLockup) throw;
        //if (fundedAmt < MINIMUM_FUND_CAP) throw;
        if (buyersAllocated) throw;
        if (!founderAllocated) throw;

        // foreach buyer
        // balances[buyer] = TOKEN_SUPPLY_CAP * ( funded[buyer] / safeAdd(totalFunded + totalGifted) );

        // old example code...
        // balances[founder] = safeAdd(balances[founder], presaleTokenSupply * founderAllocation / (1 ether));
        // totalSupply = safeAdd(totalSupply, presaleTokenSupply * founderAllocation / (1 ether));
        buyersAllocated = true;
        AllocateBuyersTokensEvent(msg.sender);
    }

    function allocateFounderPercent(address recipient, uint percent) {
        if(msg.sender!=foundation) throw;
        if(block.number<startBlock) throw;
        if(percent + percentOthers > 100) throw;
    }

    function allocateFounderTokens() {
        if (msg.sender!=foundation) throw;
        if (block.number <= endBlock + founderLockup) throw;
        //if (fundedAmt < MINIMUM_FUND_CAP) throw;
        if (!buyersAllocated) throw;
        if (!founderAllocated) throw;

        // foreach founder
        // balances[founder] = TOKEN_SUPPLY_CAP * ( (totalGifted * founderPercents[founder]) / safeAdd(totalFunded + totalGifted) );

        // old example code...
        // balances[founder] = safeAdd(balances[founder], presaleTokenSupply * founderAllocation / (1 ether));
        // totalSupply = safeAdd(totalSupply, presaleTokenSupply * founderAllocation / (1 ether));
        founderAllocated = true;
        AllocateFounderTokensEvent(msg.sender);
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
        if (msg.sender!=foundation) throw;
        halted = true;
    }

    function unhalt() {
        if (msg.sender!=foundation) throw;
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
     *
    function changeFounder(address newFounder) {
        if (msg.sender!=foundation) throw;
        founder = newFounder;
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
        if (block.number <= endBlock + transferLockup && msg.sender!=foundation) throw;
        return super.transfer(_to, _value);
    }
    /**
     * ERC 20 Standard Token interface transfer function
     *
     * Prevent transfers until freeze period is over.
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (block.number <= endBlock + transferLockup && msg.sender!=foundation) throw;
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
