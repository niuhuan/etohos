Privacy Policy
Version: v1.0 | Effective Date: June 16, 2025

■ Data Collection Statement
1. This App does not collect, transmit, or store any of the following data:
- User identity information (name/IP/device identifiers)
- Network traffic content or metadata (connection duration/bandwidth usage)
- Communication logs between network nodes

2. Configuration file storage rules:
- All configuration files (.conf/.json) are stored only on the user's local device
- Stored in plain text by default (no encryption)
- Users can manually enable AES-GCM-256 encryption (keys are managed by users themselves)

■ Technical Implementation Details
1. Encryption scheme (optional feature):
- Encryption algorithm: AES-GCM-256 (RFC 5116 implementation)
- Key management: Users generate and store keys themselves, not uploaded to servers
- IV generation: Random 12-byte Nonce generated for each encryption

2. Network architecture:
- Fully P2P direct connection, no centralized relay servers
- NAT traversal using ICE protocol (Session Description Protocol v0.2)
- All communication links are unencrypted by default (users need to manually enable TLS)

■ User Data Control
1. You have absolute control over the following:
- Manually enable/disable encryption features through configuration files
- Delete all locally stored configuration files at any time
- Control network permissions through system-level firewalls

2. Data lifecycle:
- Configuration files remain on the device after uninstalling the App
- Manual cleanup of residual files in system storage directories is required

■ Disclaimer
1. Users are responsible for data risks caused by the following situations:
- Transmitting sensitive data when encryption is not enabled
- Storing configuration files on unencrypted disk partitions
- Configuration file leaks due to improper key management

■ Contact Information
Technical support email: fandyoffice@163.com

■ Policy Updates
We will notify changes through the following methods:
- CHANGELOG.txt included in new version installation packages
