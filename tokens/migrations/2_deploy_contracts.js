module.exports = function(deployer) {
  deployer.deploy(HumanStandardTokenFactory);
  deployer.autolink();
  deployer.deploy(HumanStandardToken);
};
