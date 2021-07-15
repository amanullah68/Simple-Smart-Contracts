pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FIXToken is ERC20, Ownable {
  string private TOKEN_NAME = "Fixation";
  string private TOKEN_SYMBOL = "FIX";

  uint private constant TOTAL_SUPPLY = 100000000;

  constructor() ERC20(TOKEN_NAME, TOKEN_SYMBOL) {
    _mint(msg.sender, TOTAL_SUPPLY);
  }

  // mint
  function mint(address to, uint256 amount) public onlyOwner() {
    _mint(to, amount);
  }

  //burn
  function burn(address from, uint256 amount) public onlyOwner() {
    _burn(from, amount);
  }
}
