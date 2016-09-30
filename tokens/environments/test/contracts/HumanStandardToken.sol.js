// Factory "morphs" into a Pudding class.
// The reasoning is that calling load in each context
// is cumbersome.

(function() {

  var contract_data = {
    abi: [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"},{"constant":true,"inputs":[],"name":"version","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"},{"name":"_extraData","type":"bytes"}],"name":"approveAndCall","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"type":"function"},{"inputs":[{"name":"_initialAmount","type":"uint256"},{"name":"_tokenName","type":"string"},{"name":"_decimalUnits","type":"uint8"},{"name":"_tokenSymbol","type":"string"}],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}],
    binary: "60a060405260046060527f48302e31000000000000000000000000000000000000000000000000000000006080526006805460008290527f48302e310000000000000000000000000000000000000000000000000000000882556100b5907ff652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d3f602060026001841615610100026000190190931692909204601f01919091048101905b8082111561017957600081556001016100a1565b505060405161097d38038061097d83398101604052808051906020019091908051820191906020018051906020019091908051820191906020015050836000600050600033600160a060020a0316815260200190815260200160002060005081905550836002600050819055508260036000509080519060200190828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061017d57805160ff19168380011785555b506101ad9291506100a1565b5090565b8280016001018555821561016d579182015b8281111561016d57825182600050559160200191906001019061018f565b50506004805460ff19168317905560058054825160008390527f036b6384b5eca791c62761152d0c79bb0604c104a5fb6f4eb0703f3154bb3db0602060026001851615610100026000190190941693909304601f90810184900482019386019083901061022d57805160ff19168380011785555b5061025d9291506100a1565b82800160010185558215610221579182015b8281111561022157825182600050559160200191906001019061023f565b50505050505061070c806102716000396000f36060604052361561008d5760e060020a600035046306fdde038114610095578063095ea7b3146100f257806318160ddd1461015d57806323b872dd14610166578063313ce567146102c757806354fd4d50146102d357806370a082311461033057806395d89b411461035e578063a9059cbb146103bb578063cae9ca511461044d578063dd62ed3e14610618575b610000610002565b61064c60038054602060026001831615610100026000190190921691909104601f810182900490910260809081016040526060828152929190828280156106ef5780601f106106c4576101008083540402835291602001916106ef565b61034c60043560243533600160a060020a03908116600081815260016020908152604080832094871680845294825282208590556060858152919392917f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b9259190a35060015b92915050565b61034c60025481565b61034c600435602435604435600160a060020a0383166000908152602081905260408120548290108015906101b9575060016020908152604080832033600160a060020a03168452909152812054829010155b80156101c55750600082115b1561070757816000600050600085600160a060020a03168152602001908152602001600020600082828250540192505081905550816000600050600086600160a060020a03168152602001908152602001600020600082828250540392505081905550816001600050600086600160a060020a03168152602001908152602001600020600050600033600160a060020a0316815260200190815260200160002060008282825054039250508190555082600160a060020a031684600160a060020a03167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040518082815260200191505060405180910390a35060016106fb565b6106ba60045460ff1681565b61064c60068054602060026001831615610100026000190190921691909104601f810182900490910260809081016040526060828152929190828280156106ef5780601f106106c4576101008083540402835291602001916106ef565b600160a060020a03600435166000908152602081905260409020545b60408051918252519081900360200190f35b61064c60058054602060026001831615610100026000190190921691909104601f810182900490910260809081016040526060828152929190828280156106ef5780601f106106c4576101008083540402835291602001916106ef565b61034c60043560243533600160a060020a03166000908152602081905260408120548290108015906103ed5750600082115b1561070257604080822080548490039055600160a060020a03808516808452918320805485019055606084815233909116907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef90602090a3506001610157565b60806020604435600481810135601f81018490049093028401604052606083815261034c948235946024803595606494939101919081908382808284375094965050505050505033600160a060020a03908116600081815260016020908152604080832094881680845294825280832087905580518781529051929493927f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925929181900390910190a383600160a060020a031660405180807f72656365697665417070726f76616c28616464726573732c75696e743235362c81526020017f616464726573732c627974657329000000000000000000000000000000000000815260200150602e019050604051809103902060e060020a8091040260e060020a9004338530866040518560e060020a0281526004018085600160a060020a0316815260200184815260200183600160a060020a031681526020018280519060200190808383829060006004602084601f0104600f02600301f150905090810190601f1680156105f05780820380516001836020036101000a031916815260200191505b509450505050506000604051808303816000876161da5a03f19250505015156106f757610002565b61034c600435602435600160a060020a03808316600090815260016020908152604080832093851683529290522054610157565b60405180806020018281038252838181518152602001915080519060200190808383829060006004602084601f0104600f02600301f150905090810190601f1680156106ac5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6060908152602090f35b820191906000526020600020905b8154815290600101906020018083116106d257829003601f168201915b505050505081565b5060015b9392505050565b610157565b6106fb56",
    unlinked_binary: "60a060405260046060527f48302e31000000000000000000000000000000000000000000000000000000006080526006805460008290527f48302e310000000000000000000000000000000000000000000000000000000882556100b5907ff652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d3f602060026001841615610100026000190190931692909204601f01919091048101905b8082111561017957600081556001016100a1565b505060405161097d38038061097d83398101604052808051906020019091908051820191906020018051906020019091908051820191906020015050836000600050600033600160a060020a0316815260200190815260200160002060005081905550836002600050819055508260036000509080519060200190828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061017d57805160ff19168380011785555b506101ad9291506100a1565b5090565b8280016001018555821561016d579182015b8281111561016d57825182600050559160200191906001019061018f565b50506004805460ff19168317905560058054825160008390527f036b6384b5eca791c62761152d0c79bb0604c104a5fb6f4eb0703f3154bb3db0602060026001851615610100026000190190941693909304601f90810184900482019386019083901061022d57805160ff19168380011785555b5061025d9291506100a1565b82800160010185558215610221579182015b8281111561022157825182600050559160200191906001019061023f565b50505050505061070c806102716000396000f36060604052361561008d5760e060020a600035046306fdde038114610095578063095ea7b3146100f257806318160ddd1461015d57806323b872dd14610166578063313ce567146102c757806354fd4d50146102d357806370a082311461033057806395d89b411461035e578063a9059cbb146103bb578063cae9ca511461044d578063dd62ed3e14610618575b610000610002565b61064c60038054602060026001831615610100026000190190921691909104601f810182900490910260809081016040526060828152929190828280156106ef5780601f106106c4576101008083540402835291602001916106ef565b61034c60043560243533600160a060020a03908116600081815260016020908152604080832094871680845294825282208590556060858152919392917f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b9259190a35060015b92915050565b61034c60025481565b61034c600435602435604435600160a060020a0383166000908152602081905260408120548290108015906101b9575060016020908152604080832033600160a060020a03168452909152812054829010155b80156101c55750600082115b1561070757816000600050600085600160a060020a03168152602001908152602001600020600082828250540192505081905550816000600050600086600160a060020a03168152602001908152602001600020600082828250540392505081905550816001600050600086600160a060020a03168152602001908152602001600020600050600033600160a060020a0316815260200190815260200160002060008282825054039250508190555082600160a060020a031684600160a060020a03167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040518082815260200191505060405180910390a35060016106fb565b6106ba60045460ff1681565b61064c60068054602060026001831615610100026000190190921691909104601f810182900490910260809081016040526060828152929190828280156106ef5780601f106106c4576101008083540402835291602001916106ef565b600160a060020a03600435166000908152602081905260409020545b60408051918252519081900360200190f35b61064c60058054602060026001831615610100026000190190921691909104601f810182900490910260809081016040526060828152929190828280156106ef5780601f106106c4576101008083540402835291602001916106ef565b61034c60043560243533600160a060020a03166000908152602081905260408120548290108015906103ed5750600082115b1561070257604080822080548490039055600160a060020a03808516808452918320805485019055606084815233909116907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef90602090a3506001610157565b60806020604435600481810135601f81018490049093028401604052606083815261034c948235946024803595606494939101919081908382808284375094965050505050505033600160a060020a03908116600081815260016020908152604080832094881680845294825280832087905580518781529051929493927f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925929181900390910190a383600160a060020a031660405180807f72656365697665417070726f76616c28616464726573732c75696e743235362c81526020017f616464726573732c627974657329000000000000000000000000000000000000815260200150602e019050604051809103902060e060020a8091040260e060020a9004338530866040518560e060020a0281526004018085600160a060020a0316815260200184815260200183600160a060020a031681526020018280519060200190808383829060006004602084601f0104600f02600301f150905090810190601f1680156105f05780820380516001836020036101000a031916815260200191505b509450505050506000604051808303816000876161da5a03f19250505015156106f757610002565b61034c600435602435600160a060020a03808316600090815260016020908152604080832093851683529290522054610157565b60405180806020018281038252838181518152602001915080519060200190808383829060006004602084601f0104600f02600301f150905090810190601f1680156106ac5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6060908152602090f35b820191906000526020600020905b8154815290600101906020018083116106d257829003601f168201915b505050505081565b5060015b9392505050565b610157565b6106fb56",
    address: "",
    generated_with: "2.0.9",
    contract_name: "HumanStandardToken"
  };

  function Contract() {
    if (Contract.Pudding == null) {
      throw new Error("HumanStandardToken error: Please call load() first before creating new instance of this contract.");
    }

    Contract.Pudding.apply(this, arguments);
  };

  Contract.load = function(Pudding) {
    Contract.Pudding = Pudding;

    Pudding.whisk(contract_data, Contract);

    // Return itself for backwards compatibility.
    return Contract;
  }

  Contract.new = function() {
    if (Contract.Pudding == null) {
      throw new Error("HumanStandardToken error: Please call load() first before calling new().");
    }

    return Contract.Pudding.new.apply(Contract, arguments);
  };

  Contract.at = function() {
    if (Contract.Pudding == null) {
      throw new Error("HumanStandardToken error: Please call load() first before calling at().");
    }

    return Contract.Pudding.at.apply(Contract, arguments);
  };

  Contract.deployed = function() {
    if (Contract.Pudding == null) {
      throw new Error("HumanStandardToken error: Please call load() first before calling deployed().");
    }

    return Contract.Pudding.deployed.apply(Contract, arguments);
  };

  if (typeof module != "undefined" && typeof module.exports != "undefined") {
    module.exports = Contract;
  } else {
    // There will only be one version of Pudding in the browser,
    // and we can use that.
    window.HumanStandardToken = Contract;
  }

})();
