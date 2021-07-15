pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Wrapper {
    using SafeMath for uint;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));
    
    address public tokenA;
    address public tokenB;
    address public tokenC;
    address owner;

    uint8 private check = 0;
    
    event Swap(
        address indexed sender,
        uint amountIn,
        uint amountOut,
        address indexed to
    );
    
    constructor() {
        owner = address(this);
    }
    
    // called once at time of deployment
    function initialize(address _tokenA, address _tokenB, address _tokenC) external {
        require(owner == address(this), 'ALREADY INITIALIZED'); // sufficient check
        require(check == 0, 'ALREADY INITIALIZED'); // sufficient check
        tokenA = _tokenA;
        tokenB = _tokenB;
        tokenC = _tokenC;
        check = 1;
    }
    
    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TRANSFER_FAILED');
    }
    
    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to, uint amount) external returns (uint liquidity) {
        require(tokenA != address(0) && tokenB != address(0) && tokenC != address(0), 'NOT_INITIALIZED');
        bytes4 MINTOR = bytes4(keccak256(bytes('mint(address,uint256)')));
        (bool success, bytes memory data) = tokenC.call(abi.encodeWithSelector(MINTOR, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'MINTING_FAILED');
    }

    /**
     * Convert an amount of input token_ to an equivalent amount of the output token
     *
     * @param _token address of token to swap
     * @param amount amount of token to swap/receive
     */
    function swap(address _token, uint amount, address to) external {
        require(tokenA != address(0) && tokenB != address(0) && tokenC != address(0), 'NOT_INITIALIZED');
        require(amount > 0, 'INSUFFICIENT_AMOUNT');
        require(_token == tokenA || _token == tokenB, 'INVALID_TOKEN_ADDRESS');
        require(to != tokenA && to != tokenB && to != tokenC, 'INVALID_TO');
        _safeTransfer(_token, address(this), amount);
        _safeTransfer(tokenC, to, amount);
        
        emit Swap(address(this), amount, amount, to);
    }

    /**
     * Convert an amount of the output token to an equivalent amount of input token_
     *
     * @param _token address of token to receive
     * @param amount amount of token to swap/receive
     */
    function unswap(address _token, uint amount, address to) external {
        require(tokenA != address(0) && tokenB != address(0) && tokenC != address(0), 'NOT_INITIALIZED');
        require(amount > 0, 'INSUFFICIENT_AMOUNT');
        require(_token == tokenA || _token == tokenB, 'INVALID_TOKEN_ADDRESS');
        require(to != tokenA && to != tokenB && to != tokenC, 'INVALID_TO');
        _safeTransfer(tokenC, address(this), amount);
        _safeTransfer(_token, to, amount);
    }
}
