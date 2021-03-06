pragma solidity ^0.4.23;
import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "openzeppelin-solidity/contracts/ownership/HasNoEther.sol";
import "openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol";


contract Whitelist is Pausable {
  mapping(address => bool) public whitelist;
  uint public numberOfWhitelists;
  event WhitelistedAddressAdded(address addr);
  event WhitelistedAddressRemoved(address addr);

  /**
   * @dev Throws if called by any account that's not whitelisted.
   */
  modifier onlyWhitelisted() {
    require(whitelist[msg.sender]);
    _;
  }

  constructor() public {
    whitelist[msg.sender] = true;
    numberOfWhitelists = 1;
    emit WhitelistedAddressAdded(msg.sender);
  }
  /**
   * @dev add an address to the whitelist
   * @param addr address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
  function addAddressToWhitelist(address addr) onlyWhitelisted whenNotPaused public returns(bool success) {
    if (!whitelist[addr]) {
      whitelist[addr] = true;
      numberOfWhitelists++;
      emit WhitelistedAddressAdded(addr);
      success = true;
    }
  }

  /**
   * @dev remove an address from the whitelist
   * @param addr address
   * @return true if the address was removed from the whitelist,
   * false if the address wasn't in the whitelist in the first place
   */
  function removeAddressFromWhitelist(address addr) onlyWhitelisted whenNotPaused public returns(bool success) {
    require(numberOfWhitelists > 1);
    if (whitelist[addr]) {
      whitelist[addr] = false;
      numberOfWhitelists--;
      emit WhitelistedAddressRemoved(addr);
      success = true;
    }
  }

}

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract SimpleToken is StandardToken, BurnableToken, Whitelist, HasNoEther, CanReclaimToken {

  string public constant name = "KubitCoin"; // solium-disable-line uppercase
  string public constant symbol = "KBX"; // solium-disable-line uppercase
  uint8 public constant decimals = 18; // solium-disable-line uppercase
  uint256 public constant INITIAL_SUPPLY = 500000000 * (10 ** uint256(decimals));

  mapping(address => bool) public blacklist;
  event BlacklistedAddressAdded(address _address);
  event BlacklistedAddressRemoved(address _address);

  modifier canTransfer(address from, address to) {
    if(blacklist[from]) {
      if(whitelist[to]) {
        _;
      } else {
        revert();
      }
    } else {
      _;
    }
  }

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }


  function transfer(address _to, uint _value) canTransfer(msg.sender, _to) whenNotPaused public  returns (bool success) {
   return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) canTransfer(_from, _to)  whenNotPaused public  returns (bool success) {
    return super.transferFrom(_from, _to, _value);
  }


  function approve(address _spender, uint256 _value) whenNotPaused public returns (bool) {
    super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue)  whenNotPaused public returns (bool) {
    super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue)  whenNotPaused public returns (bool) {
    super.decreaseApproval(_spender, _subtractedValue);
  }

  function burn(uint256 value) public onlyWhitelisted whenNotPaused {
    super.burn(value);
  }

  function addAddressToBlacklist(address addr) onlyWhitelisted whenNotPaused public returns(bool success) {
    if (!blacklist[addr]) {
      blacklist[addr] = true;
      emit BlacklistedAddressAdded(addr);
      success = true;
    }
  }

  function removeAddressFromBlacklist(address addr) onlyWhitelisted whenNotPaused public returns(bool success) {
    if (blacklist[addr]) {
      blacklist[addr] = false;
      emit BlacklistedAddressRemoved(addr);
      success = true;
    }
  }
}
