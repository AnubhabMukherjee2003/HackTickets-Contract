// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedTicketRegistry is Ownable {

    uint256 private _nextTicketId;
    uint256 private _nextEventId;

    constructor() Ownable(msg.sender) {}

    // ----------------------------
    // STRUCTS
    // ----------------------------

    struct EventData {
        string name;
        string location;
        uint256 date;        // timestamp
        uint256 price;       // informational (enforced off-chain)
        uint256 capacity;
        uint256 ticketsSold;
        bool active;
    }

    struct Ticket {
        uint256 eventId;
        bytes32 phoneHash;   // keccak256(phone + eventId + salt)
        bool used;
        bytes32 paymentId;   // hashed payment reference
    }

    // ----------------------------
    // STORAGE
    // ----------------------------

    mapping(uint256 => EventData) public events;
    mapping(uint256 => Ticket) public tickets;

    // phoneHash => ticketIds
    mapping(bytes32 => uint256[]) private userTickets;

    // prevent duplicate payment usage
    mapping(bytes32 => bool) public usedPayments;

    // ----------------------------
    // EVENTS
    // ----------------------------

    event EventCreated(uint256 indexed eventId);
    event TicketMinted(uint256 indexed ticketId, uint256 indexed eventId);
    event TicketUsed(uint256 indexed ticketId);

    // ----------------------------
    // EVENT MANAGEMENT
    // ----------------------------

    function createEvent(
        string memory name,
        string memory location,
        uint256 date,
        uint256 price,
        uint256 capacity
    ) external onlyOwner {

        require(capacity > 0, "Invalid capacity");

        events[_nextEventId] = EventData({
            name: name,
            location: location,
            date: date,
            price: price,
            capacity: capacity,
            ticketsSold: 0,
            active: true
        });

        emit EventCreated(_nextEventId);
        _nextEventId++;
    }

    function setEventStatus(uint256 eventId, bool status)
        external
        onlyOwner
    {
        events[eventId].active = status;
    }

    // ----------------------------
    // TICKET MINTING
    // ----------------------------

    function mintTicket(
        uint256 eventId,
        bytes32 phoneHash,
        bytes32 paymentId
    ) external onlyOwner {

        EventData storage eventData = events[eventId];

        require(eventData.active, "Event inactive");
        require(eventData.ticketsSold < eventData.capacity, "Sold out");
        require(!usedPayments[paymentId], "Payment already used");

        uint256 ticketId = _nextTicketId;
        _nextTicketId++;

        tickets[ticketId] = Ticket({
            eventId: eventId,
            phoneHash: phoneHash,
            used: false,
            paymentId: paymentId
        });

        userTickets[phoneHash].push(ticketId);
        usedPayments[paymentId] = true;

        eventData.ticketsSold++;

        emit TicketMinted(ticketId, eventId);
    }

    // ----------------------------
    // ENTRY VALIDATION
    // ----------------------------

    function markAsUsed(
        uint256 ticketId,
        bytes32 inputHash
    ) external onlyOwner {

        Ticket storage ticket = tickets[ticketId];

        require(!ticket.used, "Already used");
        require(ticket.phoneHash == inputHash, "Phone mismatch");

        ticket.used = true;

        emit TicketUsed(ticketId);
    }

    // ----------------------------
    // VIEW FUNCTIONS
    // ----------------------------

    function getUserTickets(bytes32 phoneHash)
        external
        view
        returns (uint256[] memory)
    {
        return userTickets[phoneHash];
    }

    function getTicket(uint256 ticketId)
        external
        view
        returns (Ticket memory)
    {
        return tickets[ticketId];
    }

    function getEvent(uint256 eventId)
        external
        view
        returns (EventData memory)
    {
        return events[eventId];
    }

    function totalEvents() external view returns (uint256) {
        return _nextEventId;
    }

    function totalTickets() external view returns (uint256) {
        return _nextTicketId;
    }
}
