// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract FundManager is
    Initializable,
    AccessControlEnumerableUpgradeable
{
    using SafeERC20 for IERC20;
    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");

    IERC20 public USDC;

    uint256 public totalDeposit;
    uint256 public totalWithdraw;
    mapping(address => uint256) public depositOf;
    mapping(address => uint256) public withdrawOf;

    event Deposit(address user, uint256 amount);
    event Withdraw(address[] users, uint256[] amounts);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _USDC,
        address admin,
        address withdrawer
    ) public initializer {
        __AccessControlEnumerable_init();

        USDC = IERC20(_USDC);

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(WITHDRAWER_ROLE, withdrawer);
    }

    function deposit(uint256 amount) external {
        USDC.safeTransferFrom(msg.sender, address(this), amount);
        totalDeposit += amount;
        depositOf[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(
        address[] memory users,
        uint256[] memory amounts
    ) external onlyRole(WITHDRAWER_ROLE) {
        require(users.length == amounts.length, "Invalid Input");

        for (uint256 i = 0; i < users.length; ++i) {
            USDC.safeTransfer(users[i], amounts[i]);
            totalWithdraw += amounts[i];
            withdrawOf[users[i]] += amounts[i];
        }

        emit Withdraw(users, amounts);
    }
}
