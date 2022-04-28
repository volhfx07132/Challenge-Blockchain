// SPDX-License-Identifier: MIT

pragma solidity 0.5.7;


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Challenge {
    using SafeMath for uint256;

    /** @param ChallengeState currentState of challenge:
         1 : in processs
         2 : success
         3 : failed
         4 : gave up
         5 : closed
    */
    enum ChallengeState{
        PROCESSING,
        SUCCESS,
        FAILED,
        GAVE_UP,
        CLOSED
    }

    /** @dev securityAddress address to verify app signature.
    */
    address constant private securityAddress = 0x547d99b46B58C313F95A09913C517dB4E42437aB;

    /** @dev sponsor sponsor of challenge.
    */
    address payable public sponsor;

    /** @dev challenger challenger of challenge.
    */
    address payable public challenger;

    /** @dev serverAddress serverAddress of challenge.
    */
    address payable serverAddress;

    /** @dev awardReceivers list of receivers when challenge success and fail, start by success list.
    */
    address payable[] public awardReceivers;

    /** @dev awardReceiversApprovals list of award for receivers when challenge success and fail, start by success list.
    */
    uint256[] public awardReceiversApprovals;

    /** @dev historyData number of steps each day in challenge.
    */
    uint256[] historyData;

    /** @dev historyDate date in challenge.
    */
    uint256[] historyDate;

    /** @dev index index to split array receivers.
    */
    uint256 public index;

    /** @dev totalReward total reward receiver can receive in challenge.
    */
    uint256 public totalReward;

    /** @dev gasFee ETH for challenger transaction fee. Transfer for challenger when create challenge.
    */
    uint256 public gasFee;

    /** @dev serverSuccessFee ETH for sever when challenge success.
    */
    uint256 public serverSuccessFee;

    /** @dev serverFailureFee ETH for sever when challenge fail.
    */
    uint256 public serverFailureFee;

    /** @dev duration duration of challenge from start to end time.
    */
    uint256 public duration;

    /** @dev startTime startTime of challenge.
    */
    uint256 public startTime;

    /** @dev endTime endTime of challenge.
    */
    uint256 public endTime;

    /** @dev dayRequired number of day which challenger need to finish challenge.
    */
    uint256 public dayRequired;

    /** @dev goal number of steps which challenger need to finish in day.
    */
    uint256 public goal;

    /** @dev currentStatus currentStatus of challenge.
    */
    uint256 currentStatus;

    /** @dev sumAwardSuccess sumAwardSuccess of challenge.
    */
    uint256 sumAwardSuccess;

    /** @dev sumAwardFail sumAwardFail of challenge.
    */
    uint256 sumAwardFail;

    /** @dev sequence submit daily result count number of challenger.
    */
    uint256 sequence;

    /** @dev allowGiveUp challenge allow give up or not.
    */
    bool public allowGiveUp;

    /** @dev isFinished challenge finish or not.
    */
    bool public isFinished;

    /** @dev isSuccess challenge success or not.
    */
    bool public isSuccess;

    /** @dev choiceAwardToSponsor all award will go to sponsor wallet when challenger give up or not.
    */
    bool public choiceAwardToSponsor;

    /** @dev selectGiveUpStatus challenge need be give up one time.
    */
    bool selectGiveUpStatus;

    /** @dev approvalSuccessOf get amount of ETH an `address` can receive when ckhallenge success.
    */
    mapping(address => uint256) public approvalSuccessOf;

    /** @dev approvalFailOf get amount of ETH an `address` can receive when challenge fail.
    */
    mapping(address => uint256) public approvalFailOf;

    /** @dev stepOn get step on a day.
    */
    mapping(uint256 => uint256) public stepOn;

    /** @dev verifyMessage keep track and reject double secure message.
    */
    mapping(string => bool) public verifyMessage;

    event SendDailyResult(uint256 indexed currentStatus);
    event FundTransfer(address indexed to, uint256 indexed valueSend);
    event GiveUp(address indexed from);
    event CloseChallenge(bool indexed challengeStatus);

    /**
     * @dev Action should be called in challenge time.
     */
    modifier onTime() {
        require(block.timestamp >= startTime, "Challenge has not started yet");
        require(block.timestamp <= endTime, "Challenge was finished");
        _;
    }

    /**
     * @dev Action should be called in required time.
     */
    modifier onTimeSendResult() {
        require(block.timestamp <= endTime.add(2 days), "Challenge was finished");
        require(block.timestamp >= startTime, "Challenge has not started yet");
        _;
    }

    /**
     * @dev Action should be called after challenge start.
     */
    modifier mustStart() {
        require(block.timestamp >= startTime, "Challenge has not started yet");
        _;
    }

    /**
     * @dev Action should be called after challenge finish.
     */
    modifier afterFinish() {
        require(block.timestamp > endTime.add(2 days), "Challenge has not finished yet");
        _;
    }

    /**
     * @dev Action should be called when challenge is running.
     */
    modifier available() {
        require(!isFinished, "Challenge was finished");
        _;
    }

    /**
     * @dev Action should be called when challenge was allowed give up.
     */
    modifier canGiveUp() {
        require(allowGiveUp, "Can not give up");
        _;
    }

    /**
     * @dev Value send to contract should be equal with `amount`.
     */
    modifier validateAward(uint256 _amount) {
        require(msg.value == _amount, "Invalid award");
        _;
    }

    /**
     * @dev Action only called from sever or sponsor.
     */
    modifier onlyServerOrSponsor() {
        require(msg.sender == serverAddress || msg.sender == sponsor, "You do not have right");
        _;
    }

    /**
     * @dev User only call give up one time.
     */
    modifier notSelectGiveUp() {
        require(!selectGiveUpStatus, "This challenge was give up");
        _;
    }

    /**
     * @dev Action only called from stakeholders.
     */
    modifier onlyStakeHolders() {
        require(msg.sender == challenger || msg.sender == sponsor, "Only stakeholders can call this function");
        _;
    }

    /**
     * @dev Action only called from challenger.
     */
    modifier onlyChallenger() {
        require(msg.sender == challenger, "Only challenger can call this function");
        _;
    }

    /**
     * @dev verify app signature.
     */
    modifier verifySignature(string memory message, uint8 v, bytes32 r, bytes32 s) {
        require(securityAddress == verifyString(message, v, r, s), "Cant send");
        _;
    }

    /**
     * @dev verify double sending message.
     */
    modifier rejectDoubleMessage(string memory message) {
        require(!verifyMessage[message], "Cant send");
        _;
    }

    /**
     * @dev verify challenge success or not before close.
     */
    modifier availableForClose() {
        require(!isSuccess && !isFinished, "Cant call");
        _;
    }

    ChallengeState stateInstance;

    /**
     * @dev The Challenge constructor.
     * @param _stakeHolders : 0-sponsor, 1-challenger, 2-sever address
     * @param _primaryRequired : 0-duration, 1-start, 2-end, 3-goal
     * @param _totalReward : total amount send to challenge
     * @param _awardReceivers : list receivers address
     * @param _awardReceiversApprovals : list award for receiver address
     * @param _index : index slpit receiver array
     * @param _allowGiveUp : challenge allow give up or not
     * @param _gasData : 0-gas for sever success, 1-gas for sever fail, 2-eth for challenger transaction fee
     * @param _allAwardToSponsorWhenGiveUp : transfer all award back to sponsor or not
     */
    constructor(
        address payable[] memory _stakeHolders,
        uint256[] memory _primaryRequired,
        uint256 _totalReward,
        address payable[] memory _awardReceivers,
        uint256[] memory _awardReceiversApprovals,
        uint256 _index,
        bool _allowGiveUp,
        uint256[] memory _gasData,
        bool _allAwardToSponsorWhenGiveUp
    )
    public
    payable
    validateAward(_totalReward)
    {
        uint256 i;
        require(_index > 0, "Invalid value");
        require(_awardReceivers.length == _awardReceiversApprovals.length, "Invalid lists");

        for (i = 0; i < _index; i++) {
            require(_awardReceiversApprovals[i] > 0, "Invalid value");
            approvalSuccessOf[_awardReceivers[i]] = _awardReceiversApprovals[i];
            sumAwardSuccess = sumAwardSuccess.add(_awardReceiversApprovals[i]);
        }
        require(sumAwardSuccess.add(_gasData[2].add(_gasData[0])) == msg.value, "Invalid value");

        for (i = _index; i < _awardReceivers.length; i++) {
            require(_awardReceiversApprovals[i] > 0, "Invalid value");
            approvalFailOf[_awardReceivers[i]] = _awardReceiversApprovals[i];
            sumAwardFail = sumAwardFail.add(_awardReceiversApprovals[i]);
        }
        require(sumAwardFail.add(_gasData[2].add(_gasData[1])) == msg.value, "Invalid value");

        sponsor = _stakeHolders[0];
        challenger = _stakeHolders[1];
        serverAddress = _stakeHolders[2];
        duration = _primaryRequired[0];
        startTime = _primaryRequired[1];
        endTime = _primaryRequired[2];
        goal = _primaryRequired[3];
        dayRequired = _primaryRequired[4];
        stateInstance = ChallengeState.PROCESSING;
        awardReceivers = _awardReceivers;
        awardReceiversApprovals = _awardReceiversApprovals;
        index = _index;
        serverSuccessFee = _gasData[0];
        serverFailureFee = _gasData[1];
        gasFee = _gasData[2];
        challenger.transfer(gasFee);
        emit FundTransfer(challenger, gasFee);
        totalReward = _totalReward.sub(gasFee);
        allowGiveUp = _allowGiveUp;
        if (_allowGiveUp && _allAwardToSponsorWhenGiveUp) choiceAwardToSponsor = true;
    }

    /**
     * @dev Send daily result to challenge with security message and signature app.
     */
    function sendDailyResult(uint256[] memory _day, uint256[] memory _stepIndex, string memory message, uint8 v, bytes32 r, bytes32 s)
    public
    available
    onTimeSendResult
    onlyChallenger
    verifySignature(message, v, r, s)
    rejectDoubleMessage(message)
    {
        verifyMessage[message] = true;
        for (uint256 i = 0; i < _day.length; i++) {
            require(stepOn[_day[i]] == 0, "This day's data had already updated");
            stepOn[_day[i]] = _stepIndex[i];
            historyDate.push(_day[i]);
            historyData.push(_stepIndex[i]);
            if (_stepIndex[i] >= goal && currentStatus < dayRequired) {
                currentStatus = currentStatus.add(1);
            }
        }
        sequence = sequence.add(_day.length);
        if (sequence.sub(currentStatus) > duration.sub(dayRequired)){
            stateInstance = ChallengeState.FAILED;
            transferToListReceiverFail();
        } else {
            if (currentStatus >= dayRequired) {
                stateInstance = ChallengeState.SUCCESS;
                transferToListReceiverSuccess();
            }
        }
        emit SendDailyResult(currentStatus);
    }

    /**
     * @dev private funtion for verify message and singer.
     */
    function verifyString(string memory message, uint8 v, bytes32 r, bytes32 s) private pure returns(address signer)
    {
        string memory header = "\x19Ethereum Signed Message:\n000000";
        uint256 lengthOffset;
        uint256 length;
        assembly {
            length:= mload(message)
            lengthOffset:= add(header, 57)
        }
        require(length <= 999999, "Not provided");
        uint256 lengthLength = 0;
        uint256 divisor = 100000;
        while (divisor != 0) {
            uint256 digit = length / divisor;
            if (digit == 0) {
                if (lengthLength == 0) {
                    divisor /= 10;
                    continue;
                }
            }
            lengthLength++;
            length -= digit * divisor;
            divisor /= 10;
            digit += 0x30;
            lengthOffset++;
            assembly {
                mstore8(lengthOffset, digit)
            }
        }
        if (lengthLength == 0) {
            lengthLength = 1 + 0x19 + 1;
        } else {
            lengthLength += 1 + 0x19;
        }
        assembly {
            mstore(header, lengthLength)
        }
        bytes32 check = keccak256(abi.encodePacked(header, message));
        return ecrecover(check, v, r, s);
    }

    /**
     * @dev give up challenge.
     */
    function giveUp() external canGiveUp notSelectGiveUp onTime available onlyStakeHolders {
        uint256 amount = totalReward.sub(serverFailureFee);
        if (choiceAwardToSponsor) {
            sponsor.transfer(amount);
            emit FundTransfer(sponsor, amount);
        }
        else {
            uint256 amountToReceiverList = amount.mul(currentStatus).div(dayRequired);
            uint256 amountToSponsor = amount.sub(amountToReceiverList);
            sponsor.transfer(amountToSponsor);
            emit FundTransfer(sponsor, amountToSponsor);
            for (uint256 i = 0; i < index; i++) {
                uint256 amountTmp = approvalSuccessOf[awardReceivers[i]].mul(amountToReceiverList).div(amount);
                awardReceivers[i].transfer(amountTmp);
                emit FundTransfer(awardReceivers[i], amountTmp);
            }
        }
        serverAddress.transfer(serverFailureFee);
        emit FundTransfer(serverAddress, serverFailureFee);
        isFinished = true;
        selectGiveUpStatus = true;
        stateInstance = ChallengeState.GAVE_UP;
        emit GiveUp(msg.sender);
    }

    /**
     * @dev Close challenge.
     */
    function closeChallenge() external onlyStakeHolders afterFinish availableForClose
    {
        stateInstance = ChallengeState.CLOSED;
        transferToListReceiverFail();
    }

    /**
     * @dev Destroy challenge.
     */
    function destroyChallenge() external onlyServerOrSponsor {
        if (getContractBalance() > serverFailureFee) {
           serverAddress.transfer(serverFailureFee);
        }
        selfdestruct(sponsor);
    }

    /**
     * @dev Private function for transfer all award to receivers when challenge success.
     */
    function transferToListReceiverSuccess() private {
        serverAddress.transfer(serverSuccessFee);
        emit FundTransfer(serverAddress, serverSuccessFee);
        for (uint256 i = 0; i < index; i++) {
            awardReceivers[i].transfer(approvalSuccessOf[awardReceivers[i]]);
            emit FundTransfer(awardReceivers[i], approvalSuccessOf[awardReceivers[i]]);
        }
        isSuccess = true;
        isFinished = true;
    }

    /**
     * @dev Private function for transfer all award to receivers when challenge fail.
     */
    function transferToListReceiverFail() private {
        serverAddress.transfer(serverFailureFee);
        emit FundTransfer(serverAddress, serverFailureFee);
        for (uint256 i = index; i < awardReceivers.length; i++) {
            awardReceivers[i].transfer(approvalFailOf[awardReceivers[i]]);
            emit FundTransfer(awardReceivers[i], approvalFailOf[awardReceivers[i]]);
        }
        isFinished = true;
        emit CloseChallenge(false);
    }

    /**
     * @dev get balance of challenge.
     */
    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }

    /**
     * @dev get information of challenge.
     */
    function getChallengeInfo() external view returns(uint256 challengeCleared, uint256 challengeDayRequired, uint256 daysRemained) {
        return (
            currentStatus,
            dayRequired,
            dayRequired.sub(currentStatus)
        );
    }

    /**
     * @dev get history of challenge.
     */
    function getChallengeHistory() external view returns(uint256[] memory date, uint256[] memory data) {
        return (historyDate, historyData);
    }

    /**
     * @dev get state of challenge.
     */
    function getState() external view returns (ChallengeState) {
        return stateInstance;
    }

}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal { }
}

contract ChallengeWithToken {
    using SafeMath for uint256;

    /** @param ChallengeState currentState of challenge:
         1 : in processs
         2 : success
         3 : failed
         4 : gave up
         5 : closed
    */
    enum ChallengeState{
        PROCESSING,
        SUCCESS,
        FAILED,
        GAVE_UP,
        CLOSED
    }

    /** @dev securityAddress address to verify app signature.
    */
    address constant private securityAddress = 0x547d99b46B58C313F95A09913C517dB4E42437aB;
    
    /** @dev tokenAddress address of erc-20 contract.
    */
    address private tokenAddress;

    /** @dev sponsor sponsor of challenge.
    */
    address payable public sponsor;

    /** @dev challenger challenger of challenge.
    */
    address payable public challenger;

    /** @dev serverAddress serverAddress of challenge.
    */
    address payable serverAddress;

    /** @dev awardReceivers list of receivers when challenge success and fail, start by success list.
    */
    address payable[] public awardReceivers;

    /** @dev awardReceiversApprovals list of award for receivers when challenge success and fail, start by success list.
    */
    uint256[] public awardReceiversApprovals;

    /** @dev historyData number of steps each day in challenge.
    */
    uint256[] historyData;

    /** @dev historyDate date in challenge.
    */
    uint256[] historyDate;

    /** @dev index index to split array receivers.
    */
    uint256 public index;

    /** @dev totalReward total reward receiver can receive in challenge.
    */
    uint256 public totalReward;

    /** @dev gasFee ETH for challenger transaction fee. Transfer for challenger when create challenge.
    */
    uint256 public gasFee;

    /** @dev serverSuccessFee ETH for sever when challenge success.
    */
    uint256 public serverSuccessFee;

    /** @dev serverFailureFee ETH for sever when challenge fail.
    */
    uint256 public serverFailureFee;

    /** @dev duration duration of challenge from start to end time.
    */
    uint256 public duration;

    /** @dev startTime startTime of challenge.
    */
    uint256 public startTime;

    /** @dev endTime endTime of challenge.
    */
    uint256 public endTime;

    /** @dev dayRequired number of day which challenger need to finish challenge.
    */
    uint256 public dayRequired;

    /** @dev goal number of steps which challenger need to finish in day.
    */
    uint256 public goal;

    /** @dev currentStatus currentStatus of challenge.
    */
    uint256 currentStatus;

    /** @dev sumAwardSuccess sumAwardSuccess of challenge.
    */
    uint256 sumAwardSuccess;

    /** @dev sumAwardFail sumAwardFail of challenge.
    */
    uint256 sumAwardFail;

    /** @dev sequence submit daily result count number of challenger.
    */
    uint256 sequence;

    /** @dev allowGiveUp challenge allow give up or not.
    */
    bool public allowGiveUp;

    /** @dev isFinished challenge finish or not.
    */
    bool public isFinished;

    /** @dev isSuccess challenge success or not.
    */
    bool public isSuccess;

    /** @dev choiceAwardToSponsor all award will go to sponsor wallet when challenger give up or not.
    */
    bool public choiceAwardToSponsor;

    /** @dev selectGiveUpStatus challenge need be give up one time.
    */
    bool selectGiveUpStatus;

    /** @dev approvalSuccessOf get amount of ETH an `address` can receive when ckhallenge success.
    */
    mapping(address => uint256) public approvalSuccessOf;

    /** @dev approvalFailOf get amount of ETH an `address` can receive when challenge fail.
    */
    mapping(address => uint256) public approvalFailOf;

    /** @dev stepOn get step on a day.
    */
    mapping(uint256 => uint256) public stepOn;

    /** @dev verifyMessage keep track and reject double secure message.
    */
    mapping(string => bool) public verifyMessage;

    event SendDailyResult(uint256 indexed currentStatus);
    event FundTransfer(address indexed to, uint256 indexed valueSend);
    event GiveUp(address indexed from);
    event CloseChallenge(bool indexed challengeStatus);

    /**
     * @dev Action should be called in challenge time.
     */
    modifier onTime() {
        require(block.timestamp >= startTime, "Challenge has not started yet");
        require(block.timestamp <= endTime, "Challenge was finished");
        _;
    }

    /**
     * @dev Action should be called in required time.
     */
    modifier onTimeSendResult() {
        require(block.timestamp <= endTime.add(2 days), "Challenge was finished");
        require(block.timestamp >= startTime, "Challenge has not started yet");
        _;
    }

    /**
     * @dev Action should be called after challenge start.
     */
    modifier mustStart() {
        require(block.timestamp >= startTime, "Challenge has not started yet");
        _;
    }

    /**
     * @dev Action should be called after challenge finish.
     */
    modifier afterFinish() {
        require(block.timestamp > endTime.add(2 days), "Challenge has not finished yet");
        _;
    }

    /**
     * @dev Action should be called when challenge is running.
     */
    modifier available() {
        require(!isFinished, "Challenge was finished");
        _;
    }

    /**
     * @dev Action should be called when challenge was allowed give up.
     */
    modifier canGiveUp() {
        require(allowGiveUp, "Can not give up");
        _;
    }

    /**
     * @dev Action only called from sever or sponsor.
     */
    modifier onlyServerOrSponsor() {
        require(msg.sender == serverAddress || msg.sender == sponsor, "You do not have right");
        _;
    }

    /**
     * @dev User only call give up one time.
     */
    modifier notSelectGiveUp() {
        require(!selectGiveUpStatus, "This challenge was give up");
        _;
    }

    /**
     * @dev Action only called from stakeholders.
     */
    modifier onlyStakeHolders() {
        require(msg.sender == challenger || msg.sender == sponsor, "Only stakeholders can call this function");
        _;
    }

    /**
     * @dev Action only called from challenger.
     */
    modifier onlyChallenger() {
        require(msg.sender == challenger, "Only challenger can call this function");
        _;
    }

    /**
     * @dev verify app signature.
     */
    modifier verifySignature(string memory message, uint8 v, bytes32 r, bytes32 s) {
        require(securityAddress == verifyString(message, v, r, s), "Cant send");
        _;
    }

    /**
     * @dev verify double sending message.
     */
    modifier rejectDoubleMessage(string memory message) {
        require(!verifyMessage[message], "Cant send");
        _;
    }

    /**
     * @dev verify challenge success or not before close.
     */
    modifier availableForClose() {
        require(!isSuccess && !isFinished, "Cant call");
        _;
    }

    ChallengeState stateInstance;

     /**
     * @dev The Challenge constructor.
     * @param _stakeHolders : 0-sponsor, 1-challenger, 2-sever address, 3-token address
     * @param _primaryRequired : 0-duration, 1-start, 2-end, 3-goal, 4-day require
     * @param _totalToken : total token send to challenge
     * @param _awardReceivers : list receivers address
     * @param _awardReceiversApprovals : list award token for receiver address index slpit receiver array
     * @param _index : index slpit receiver array
     * @param _allowGiveUp : challenge allow give up or not
     * @param _gasData : 0-token for sever success, 1-token for sever fail, 2-eth for challenger transaction fee
     * @param _allAwardToSponsorWhenGiveUp : transfer all award back to sponsor or not
     */
    constructor(
        address payable[] memory _stakeHolders,
        uint256[] memory _primaryRequired,
        uint256 _totalToken,
        address payable[] memory _awardReceivers,
        uint256[] memory _awardReceiversApprovals,
        uint256 _index,
        bool _allowGiveUp,
        uint256[] memory _gasData,
        bool _allAwardToSponsorWhenGiveUp
    )
    public
    payable
    {
        uint256 i;
        require(_index > 0, "Invalid value");
        require(_awardReceivers.length == _awardReceiversApprovals.length, "Invalid lists");

        for (i = 0; i < _index; i++) {
            require(_awardReceiversApprovals[i] > 0, "Invalid value");
            approvalSuccessOf[_awardReceivers[i]] = _awardReceiversApprovals[i];
            sumAwardSuccess = sumAwardSuccess.add(_awardReceiversApprovals[i]);
        }
        require(sumAwardSuccess == _totalToken, "Invalid token value");

        for (i = _index; i < _awardReceivers.length; i++) {
            require(_awardReceiversApprovals[i] > 0, "Invalid value");
            approvalFailOf[_awardReceivers[i]] = _awardReceiversApprovals[i];
            sumAwardFail = sumAwardFail.add(_awardReceiversApprovals[i]);
        }
        require(sumAwardFail == _totalToken, "Invalid token value");

        sponsor = _stakeHolders[0];
        challenger = _stakeHolders[1];
        serverAddress = _stakeHolders[2];
        tokenAddress = _stakeHolders[3];
        duration = _primaryRequired[0];
        startTime = _primaryRequired[1];
        endTime = _primaryRequired[2];
        goal = _primaryRequired[3];
        dayRequired = _primaryRequired[4];
        stateInstance = ChallengeState.PROCESSING;
        awardReceivers = _awardReceivers;
        awardReceiversApprovals = _awardReceiversApprovals;
        index = _index;
        serverSuccessFee = _gasData[0];
        serverFailureFee = _gasData[1];
        gasFee = _gasData[2];
        challenger.transfer(gasFee);
        emit FundTransfer(challenger, gasFee);
        totalReward = _totalToken;
        allowGiveUp = _allowGiveUp;
        if (allowGiveUp && _allAwardToSponsorWhenGiveUp) choiceAwardToSponsor = true;
    }

    /**
     * @dev Send daily result to challenge with security message and signature app.
     */
    function sendDailyResult(uint256[] memory _day, uint256[] memory _stepIndex, string memory message, uint8 v, bytes32 r, bytes32 s)
    public
    available
    onTimeSendResult
    onlyChallenger
    verifySignature(message, v, r, s)
    rejectDoubleMessage(message)
    {
        verifyMessage[message] = true;
        for (uint256 i = 0; i < _day.length; i++) {
            require(stepOn[_day[i]] == 0, "This day's data had already updated");
            stepOn[_day[i]] = _stepIndex[i];
            historyDate.push(_day[i]);
            historyData.push(_stepIndex[i]);
            if (_stepIndex[i] >= goal && currentStatus < dayRequired) {
                currentStatus = currentStatus.add(1);
            }
        }
        sequence = sequence.add(_day.length);
        if (sequence.sub(currentStatus) > duration.sub(dayRequired)){
            stateInstance = ChallengeState.FAILED;
            transferToListReceiverFail();
        } else {
            if (currentStatus >= dayRequired) {
                stateInstance = ChallengeState.SUCCESS;
                transferToListReceiverSuccess();
            }
        }
        emit SendDailyResult(currentStatus);
    }

    /**
     * @dev private funtion for verify message and singer.
     */
    function verifyString(string memory message, uint8 v, bytes32 r, bytes32 s) private pure returns(address signer)
    {
        string memory header = "\x19Ethereum Signed Message:\n000000";
        uint256 lengthOffset;
        uint256 length;
        assembly {
            length:= mload(message)
            lengthOffset:= add(header, 57)
        }
        require(length <= 999999, "Not provided");
        uint256 lengthLength = 0;
        uint256 divisor = 100000;
        while (divisor != 0) {
            uint256 digit = length / divisor;
            if (digit == 0) {
                if (lengthLength == 0) {
                    divisor /= 10;
                    continue;
                }
            }
            lengthLength++;
            length -= digit * divisor;
            divisor /= 10;
            digit += 0x30;
            lengthOffset++;
            assembly {
                mstore8(lengthOffset, digit)
            }
        }
        if (lengthLength == 0) {
            lengthLength = 1 + 0x19 + 1;
        } else {
            lengthLength += 1 + 0x19;
        }
        assembly {
            mstore(header, lengthLength)
        }
        bytes32 check = keccak256(abi.encodePacked(header, message));
        return ecrecover(check, v, r, s);
    }

    /**
     * @dev give up challenge.
     */
    function giveUp() external canGiveUp notSelectGiveUp onTime available onlyStakeHolders {
        if (choiceAwardToSponsor) {
            TanimoToken(tokenAddress).transfer(sponsor, totalReward);
        }
        else {
            uint256 amountToReceiverList = totalReward.mul(currentStatus).div(dayRequired);
            uint256 amountToSponsor = totalReward.sub(amountToReceiverList);
            TanimoToken(tokenAddress).transfer(sponsor, amountToSponsor);
            for (uint256 i = 0; i < index; i++) {
                uint256 amountTmp = approvalSuccessOf[awardReceivers[i]].mul(amountToReceiverList).div(totalReward);
                TanimoToken(tokenAddress).transfer(awardReceivers[i], amountTmp);
            }
        }
        TanimoToken(tokenAddress).transfer(serverAddress, serverFailureFee);
        isFinished = true;
        selectGiveUpStatus = true;
        stateInstance = ChallengeState.GAVE_UP;
        emit GiveUp(msg.sender);
    }

    /**
     * @dev Close challenge.
     */
    function closeChallenge() external onlyStakeHolders afterFinish availableForClose
    {
        stateInstance = ChallengeState.CLOSED;
        transferToListReceiverFail();
    }

    /**
     * @dev Destroy challenge.
     */
    function destroyChallenge() external onlyServerOrSponsor {
        TanimoToken(tokenAddress).transfer(serverAddress, serverFailureFee);
        selfdestruct(sponsor);
    }

    /**
     * @dev Private function for transfer all award to receivers when challenge success.
     */
    function transferToListReceiverSuccess() private {
        TanimoToken(tokenAddress).transfer(serverAddress, serverSuccessFee);
        for (uint256 i = 0; i < index; i++) {
            TanimoToken(tokenAddress).transfer(awardReceivers[i], approvalSuccessOf[awardReceivers[i]]);
        }
        isSuccess = true;
        isFinished = true;
    }

    /**
     * @dev Private function for transfer all award to receivers when challenge fail.
     */
    function transferToListReceiverFail() private {
        TanimoToken(tokenAddress).transfer(serverAddress, serverFailureFee);
        for (uint256 i = index; i < awardReceivers.length; i++) {
            TanimoToken(tokenAddress).transfer(awardReceivers[i], approvalFailOf[awardReceivers[i]]);
        }
        isFinished = true;
        emit CloseChallenge(false);
    }

    function() payable external {}

    /**
     * @dev get balance of challenge.
     */
    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }

    /**
     * @dev get information of challenge.
     */
    function getChallengeInfo() external view returns(uint256 challengeCleared, uint256 challengeDayRequired, uint256 daysRemained) {
        return (
            currentStatus,
            dayRequired,
            dayRequired.sub(currentStatus)
        );
    }

    /**
     * @dev get history of challenge.
     */
    function getChallengeHistory() external view returns(uint256[] memory date, uint256[] memory data) {
        return (historyDate, historyData);
    }

    /**
     * @dev get state of challenge.
     */
    function getState() external view returns (ChallengeState) {
        return stateInstance;
    }

}

////////////////////////////////////////
    /*
     *challenge contract
    */
contract Challenges is ERC20 {
    using SafeMath for uint256;
    /**
     * @dev Value send to contract should be equal with `amount`.
     */
    modifier validateFee(uint256 _amount) {
        require(msg.value == _amount, "Invalid ETH fee");
        _;
    }
    /**
     * @dev Create new Challenge with token.
     * @param _stakeHolders : 0-sponsor, 1-challenger, 2-sever address, 3-token address
     * @param _primaryRequired : 0-duration, 1-start, 2-end, 3-goal, 4-day require
     * @param _totalReward : total reward token send to challenge
     * @param _awardReceivers : list receivers address
     * @param _awardReceiversApprovals : list award token for receiver address index slpit receiver array
     * @param _index : index slpit receiver array
     * @param _allowGiveUp : challenge allow give up or not
     * @param _gasData : 0-token for sever success, 1-token for sever fail, 2-eth for challenger transaction fee
     * @param _allAwardToSponsorWhenGiveUp : transfer all award back to sponsor or not
     */
    function CreateChallenge(
        address payable[] memory _stakeHolders,
        uint256[] memory _primaryRequired,
        uint256 _totalReward,
        address payable[] memory _awardReceivers,
        uint256[] memory _awardReceiversApprovals,
        uint256 _index,
        bool _allowGiveUp,
        uint256[] memory _gasData,
        bool _allAwardToSponsorWhenGiveUp
    )
    public
    payable
    validateFee(_gasData[2])
    returns (address challengeAddress)
    {
        ChallengeWithToken newChallengeAddress = (new ChallengeWithToken).value(msg.value)(
            _stakeHolders,
            _primaryRequired,
            _totalReward,
            _awardReceivers,
            _awardReceiversApprovals,
            _index,
            _allowGiveUp,
            _gasData,
            _allAwardToSponsorWhenGiveUp
        );
        
        if (_stakeHolders[3] == address(this)) {
            transfer(address(newChallengeAddress), _totalReward + _gasData[0]);
        } else {
            IERC20(_stakeHolders[3]).transferFrom(msg.sender, address(newChallengeAddress), _totalReward + _gasData[0]);
        }
        return address(newChallengeAddress);
    }
}

contract TanimoToken is ERC20 {
    using SafeMath for uint256;

    /**
     * @dev Value send to contract should be equal with `amount`.
     */
    modifier validateFee(uint256 _amount) {
        require(msg.value == _amount, "Invalid ETH fee");
        _;
    }

    /**
     * @dev Action only called from owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "You do not have right");
        _;
    }

    /**
     * @dev Convert rate between ETH and token.
     * if 2 : 1 ETH = 2 Token
     */
    uint8 private _rate;

    /**
     * @dev Owner of token.
     */
    address payable public _owner;

    /**
     * @dev The Tanimoto Token constructor.
     */
    constructor(address payable _ownerOfToken) ERC20("TanimoToken", "TTJP") public {
        _owner = _ownerOfToken;
        _rate = 1;
    }

    /**
     * @dev Mint token to an address.
     * @param _receiver : receivers address
     * @param _amountToken : amount token to mint
     */
    function mintToken(address _receiver, uint _amountToken) onlyOwner public {
        _mint(_receiver, _amountToken);
    }

    /**
     * @dev Burn token of an address.
     * @param _from : from address
     * @param _amountToken : amount token to burn
     */
    function burnToken(address _from, uint _amountToken) onlyOwner public {
        _burn(_from, _amountToken);
    }
    
    /**
     * @dev Get rates of token.
     */
    function getRate() public view returns (uint256) {
        return _rate;
    }

}
