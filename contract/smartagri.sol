pragma solidity ^0.8.0;

contract Project {
    struct Farm {
        uint256 id;
        address owner;
        string location;
        uint256 area;
        string cropType;
        uint256 plantingDate;
        uint256 expectedHarvest;
        bool isActive;
    }
    
    struct IoTReading {
        uint256 farmId;
        uint256 timestamp;
        uint256 soilMoisture;
        uint256 temperature;
        uint256 humidity;
    }
    
    mapping(uint256 => Farm) public farms;
    mapping(uint256 => IoTReading[]) public farmReadings;
    mapping(address => uint256[]) public ownerFarms;
    
    uint256 public farmCounter;
    
    event FarmRegistered(uint256 indexed farmId, address indexed owner);
    event IoTDataRecorded(uint256 indexed farmId, uint256 timestamp);
    event HarvestCompleted(uint256 indexed farmId, uint256 timestamp);
    
    // Core Function 1: Register Farm
    function registerFarm(
        string memory _location,
        uint256 _area,
        string memory _cropType,
        uint256 _expectedHarvest
    ) public returns (uint256) {
        farmCounter++;
        
        farms[farmCounter] = Farm({
            id: farmCounter,
            owner: msg.sender,
            location: _location,
            area: _area,
            cropType: _cropType,
            plantingDate: block.timestamp,
            expectedHarvest: _expectedHarvest,
            isActive: true
        });
        
        ownerFarms[msg.sender].push(farmCounter);
        
        emit FarmRegistered(farmCounter, msg.sender);
        return farmCounter;
    }
    
    // Core Function 2: Record IoT Data
    function recordIoTData(
        uint256 _farmId,
        uint256 _soilMoisture,
        uint256 _temperature,
        uint256 _humidity
    ) public {
        require(farms[_farmId].isActive, "Farm not active");
        require(farms[_farmId].owner == msg.sender, "Not farm owner");
        
        farmReadings[_farmId].push(IoTReading({
            farmId: _farmId,
            timestamp: block.timestamp,
            soilMoisture: _soilMoisture,
            temperature: _temperature,
            humidity: _humidity
        }));
        
        emit IoTDataRecorded(_farmId, block.timestamp);
    }
    
    // Core Function 3: Complete Harvest
    function completeHarvest(uint256 _farmId) public {
        require(farms[_farmId].isActive, "Farm not active");
        require(farms[_farmId].owner == msg.sender, "Not farm owner");
        require(block.timestamp >= farms[_farmId].expectedHarvest, "Harvest time not reached");
        
        farms[_farmId].isActive = false;
        
        emit HarvestCompleted(_farmId, block.timestamp);
    }
    
    // Helper function to get farm readings count
    function getFarmReadingsCount(uint256 _farmId) public view returns (uint256) {
        return farmReadings[_farmId].length;
    }
    
    // Helper function to get owner's farms
    function getOwnerFarms(address _owner) public view returns (uint256[] memory) {
        return ownerFarms[_owner];
    }
}
