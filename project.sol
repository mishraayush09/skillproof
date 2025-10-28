// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SkillProof
 * @dev A simple contract for decentralized skill verification.
 */
contract SkillProof {
    struct Skill {
        string name;
        string issuer;
        uint256 dateIssued;
        bool verified;
    }

    mapping(address => Skill[]) private userSkills;

    event SkillAdded(address indexed user, string skillName, string issuer);
    event SkillVerified(address indexed user, string skillName);

    /**
     * @dev Add a new skill record for the sender.
     * @param _name The name of the skill (e.g., "Solidity Developer").
     * @param _issuer The entity that issued or verified the skill.
     */
    function addSkill(string calldata _name, string calldata _issuer) external {
        userSkills[msg.sender].push(
            Skill(_name, _issuer, block.timestamp, false)
        );
        emit SkillAdded(msg.sender, _name, _issuer);
    }

    /**
     * @dev Verify a skill for a specific user (can only be done by the issuer address).
     * @param _user The address of the user whose skill is being verified.
     * @param _index The index of the skill to verify.
     */
    function verifySkill(address _user, uint256 _index) external {
        Skill storage skill = userSkills[_user][_index];
        require(
            keccak256(abi.encodePacked(skill.issuer)) ==
                keccak256(abi.encodePacked(toAsciiString(msg.sender))),
            "Only issuer can verify this skill"
        );
        skill.verified = true;
        emit SkillVerified(_user, skill.name);
    }

    /**
     * @dev Get all skills for a given user.
     * @param _user The address of the user.
     * @return Array of Skill structs.
     */
    function getSkills(address _user) external view returns (Skill[] memory) {
        return userSkills[_user];
    }

    // Helper function to convert address to string
    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(42);
        s[0] = "0";
        s[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 + i * 2] = char(hi);
            s[3 + i * 2] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}
