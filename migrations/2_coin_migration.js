var Coin = artifacts.require("Coin");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(Coin);
};  