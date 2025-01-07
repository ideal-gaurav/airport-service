// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

contract AirportServices {
    // Constants for immigration status
    uint8 constant APPROVED = 1;
    uint8 constant REJECTED = 2;
    uint8 constant UNDER_INVESTIGATION = 3;

    // Struct for storing passenger information
    struct Passenger {
        string name;
        bool validDocuments;
        uint8 immigrationStatus; // 1: Approved, 2: Rejected, 3: Under Investigation
        bool hasEligibleCard;
        uint rewardPoints;
        string purpose; // Purpose of immigration (e.g., "Study Permit", "Visitor", "PR", "Business")
    }

    // Struct for storing baggage information
    struct Baggage {
        uint weight;
        uint height;
        uint width;
        uint depth;
        string contentDescription;
        bool airlinePolicyCompliant;
        string trackingReference;
    }

    // Mapping to store passenger details by their name (instead of address)
    mapping(string => Passenger) public passengers;
    
    // Mapping to store baggage details by tracking reference
    mapping(string => Baggage) public baggageDetails;

    // Maximum allowed baggage weight in kilograms, combined size in centimeters, and individual dimension in centimeters
    uint constant MAX_BAGGAGE_WEIGHT = 23;
    uint constant MAX_COMBINED_SIZE = 220;
    uint constant MAX_SINGLE_DIMENSION = 63;

    // Function to add or update passenger information
    function registerPassenger(
        string memory _name,
        bool _validDocuments,
        bool _hasEligibleCard,
        uint _rewardPoints,
        string memory _purpose
    ) public {
        passengers[_name] = Passenger({
            name: _name,
            validDocuments: _validDocuments,
            immigrationStatus: 0, // Immigration status will be updated later
            hasEligibleCard: _hasEligibleCard,
            rewardPoints: _rewardPoints,
            purpose: _purpose
        });
    }

    // Function to manually compare two strings
    function areStringsEqual(string memory a, string memory b) internal pure returns (bool) {
        bytes memory byteA = bytes(a);
        bytes memory byteB = bytes(b);
        
        if (byteA.length != byteB.length) {
            return false; // Lengths are different, so not equal
        }

        for (uint i = 0; i < byteA.length; i++) {
            if (byteA[i] != byteB[i]) {
                return false; // Found a mismatch
            }
        }

        return true; // All characters matched
    }

    // Function to process the immigration status based on valid documents and purpose
    function processPassenger(string memory _name) public returns (string memory) {
        Passenger storage passenger = passengers[_name];

        // Ensure the passenger exists
        require(bytes(passenger.name).length > 0, "Passenger does not exist.");

        // Check if documents are valid
        if (passenger.validDocuments) {
            // Check if the immigration purpose is one of the approved types
            if (areStringsEqual(passenger.purpose, "Study Permit") || 
                areStringsEqual(passenger.purpose, "Visitor") || 
                areStringsEqual(passenger.purpose, "PR") || 
                areStringsEqual(passenger.purpose, "Business")) {
                
                passenger.immigrationStatus = APPROVED; // Set status to Approved
                return "Immigration approved based on purpose.";
            } else {
                passenger.immigrationStatus = REJECTED; // Set status to Rejected
                return "Immigration rejected due to unapproved purpose.";
            }
        } else {
            passenger.immigrationStatus = UNDER_INVESTIGATION; // Set status to Under Investigation
            return "Proceed to immigration zone for further investigation.";
        }
    }

    // Function to check the passenger's immigration status
    function getImmigrationStatus(string memory _name) public view returns (string memory) {
        Passenger storage passenger = passengers[_name];

        // Ensure the passenger exists
        require(bytes(passenger.name).length > 0, "Passenger does not exist.");

        // Return immigration status as a string
        if (passenger.immigrationStatus == APPROVED) {
            return "Approved";
        } else if (passenger.immigrationStatus == REJECTED) {
            return "Rejected";
        } else if (passenger.immigrationStatus == UNDER_INVESTIGATION) {
            return "Under Investigation";
        } else {
            return "Unknown Status";
        }
    }

    // Function to handle baggage check with weight and size validations
    function checkBaggage(
        string memory _trackingReference,
        uint _weight,
        uint _height,
        uint _width,
        uint _depth,
        string memory _contentDescription,
        bool _airlinePolicyCompliant
    ) public returns (string memory) {
        // Validate baggage weight
        if (_weight > MAX_BAGGAGE_WEIGHT) {
            return "Baggage weight exceeds 23KG limit. Please reduce weight.";
        }
        
        // Validate individual dimensions
        if (_height > MAX_SINGLE_DIMENSION || _width > MAX_SINGLE_DIMENSION || _depth > MAX_SINGLE_DIMENSION) {
            return "No single dimension should exceed 63CM. Please adjust dimensions.";
        }

        // Validate combined size (height + width + depth)
        uint combinedSize = _height + _width + _depth;
        if (combinedSize > MAX_COMBINED_SIZE) {
            return "Baggage combined dimensions exceed 220CM limit. Please reduce size.";
        }

        // Check if baggage already exists (if it does, we update it)
        if (bytes(baggageDetails[_trackingReference].trackingReference).length != 0) {
            // If baggage exists, update its details
            baggageDetails[_trackingReference].weight = _weight;
            baggageDetails[_trackingReference].height = _height;
            baggageDetails[_trackingReference].width = _width;
            baggageDetails[_trackingReference].depth = _depth;
            baggageDetails[_trackingReference].contentDescription = _contentDescription;
            baggageDetails[_trackingReference].airlinePolicyCompliant = _airlinePolicyCompliant;

            return "Baggage updated with new details.";
        } else {
            // If baggage does not exist, add it as new
            baggageDetails[_trackingReference] = Baggage({
                weight: _weight,
                height: _height,
                width: _width,
                depth: _depth,
                contentDescription: _contentDescription,
                airlinePolicyCompliant: _airlinePolicyCompliant,
                trackingReference: _trackingReference
            });

            return "Baggage accepted and tracking reference shared.";
        }
    }

    // Function to manage lounge access based on reward points
    function checkLoungeAccess(string memory _name) public view returns (string memory) {
        Passenger storage passenger = passengers[_name];

        if (passenger.hasEligibleCard) {
            if (passenger.rewardPoints > 150) {
                return "Platinum Lounge Access granted.";
            } else if (passenger.rewardPoints > 100) {
                return "Gold Lounge Access granted.";
            } else if (passenger.rewardPoints > 50) {
                return "Silver Lounge Access granted.";
            } else {
                return "Insufficient points for lounge access.";
            }
        } else {
            return "Eligible card required for lounge access.";
        }
    }
}
