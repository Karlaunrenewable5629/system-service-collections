# Mattermost Configuration

## mattermost-settings.json

The main configuration file is `mattermost-settings.json`. It uses JSON format for Mattermost settings.

### Structure

```json
{
  "SiteConfiguration": {
    "SiteName": "My Mattermost Server",
    "SiteDescription": "Mattermost Server",
    "CompanyName": "My Company",
    "EmailSettings": {
      "SendEmail": false,
      "ServiceSettings": {
        "EmailHost": "smtp.example.com",
        "EmailPort": 587,
        "Username": "user@example.com",
        "Password": "email_password",
        "SkipVerify": false
      },
      "FromAddress": "noreply@example.com"
    },
    "ServiceSettings": {
      "AnnouncementPostId": "",
      "ServiceSettingsVersion": "9.10.0"
    },
    "PrivacySettings": {
      "AllowUserToPasswordReset": true,
      "LoginAuthenticator": "password",
      "OAuthIdPConnect": false
    },
    "PostSettings": {
      "EnablePostOrdering": true,
      "EnablePostUsername": true
    },
    "PluginSettings": [],
    "FeatureSettings": {
      "EnablePostUsername": true,
      "EnablePostUsernameInRouter": true,
      "EnablePostHint": true,
      "EnableEmoji": true,
      "EnableGiphy": true,
      "EnableInAppPurchase": false
    }
  }
}
```

### Common Settings

| Setting | Description |
|---------|-------------|
| `SiteName` | Display name for your Mattermost server |
| `CompanyName` | Company/organization name |
| `EmailSettings` | Email configuration for notifications |
| `ServiceSettings` | Service announcement and version |
| `PrivacySettings` | User privacy and authentication settings |
| `PostSettings` | Post ordering and username display |
| `PluginSettings` | Enabled plugins |
| `FeatureSettings` | Feature flags enabled |

### Database Setup

| System | Commands |
|--------|----------|
| PostgreSQL | `CREATE DATABASE mattermost; CREATE USER mattermost WITH PASSWORD 'password'; GRANT ALL PRIVILEGES ON DATABASE mattermost TO mattermost;` |
| MySQL/MariaDB | `CREATE DATABASE mattermost; GRANT ALL ON mattermost.* TO 'mattermost'@'localhost' IDENTIFIED BY 'password';` |

### File Locations

| System | Config Path |
|--------|-------------|
| Linux | `/etc/mattermost/settings.json` |
| Windows | `C:\Mattermost\settings.json` |

### Reloading/Restarting

```bash
# systemd
systemctl restart mattermost

# OpenRC
rc-service mattermost restart

# Windows (NSSM)
nssm restart mattermost
```