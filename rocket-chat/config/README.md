# Rocket.Chat Configuration

## rocket-chat-settings.json

The main configuration file is `rocket-chat-settings.json`. It uses JSON format for Rocket.Chat settings.

### Structure

```json
{
  "mongoUrl": "mongodb://localhost:27017/rocketchat",
  "mongoOptions": {
    "authSource": "admin",
    "ssl": false
  },
  "portalUrl": "https://your-domain.com",
  "App": {
    "id": "web.yourdomain.com",
    "name": "Rocket.Chat",
    "description": "Rocket.Chat Server",
    "urls": "",
    "support": "",
    "settings": {
      "url": "https://your-domain.com",
      "primaryColor": "#1CCAB4",
      "fromName": "Rocket.Chat",
      "supportUrl": "",
      "termsUrl": "",
      "privacyPolicyUrl": ""
    }
  },
  "Accounts": {
    "DisableSignup": false,
    "LoginMethods": [
      "email",
      "password"
    ]
  },
  "Notifications": {
    "DefaultFromAddress": "no-reply@yourdomain.com",
    "Email": {
      "FromAddress": "no-reply@yourdomain.com",
      "Host": "smtp.example.com",
      "Port": 587,
      "Username": "user@example.com",
      "Password": "email_password",
      "SkipSSLVerification": false
    }
  },
  "Room": {
    "EnablePostUsername": true,
    "EnablePostHint": true,
    "MaxMessageLifetime": 0
  },
  "Push": {
    "Enable": true,
    "Production": {
      "APNs": {
        "Key": "",
        "KeyId": "",
        "TeamId": "",
        "Topic": "com.yourdomain.rocketchat"
      },
      "FCM": {
        "ServerKey": ""
      }
    }
  },
  "Theme": {
    "ColorPrimary": "#1CCAB4",
    "ColorSecondary": "#2A303C",
    "ColorAccent": "#1CCAB4",
    "ColorBackground": "#FFFFFF"
  }
}
```

### Common Settings

| Setting | Description |
|---------|-------------|
| `mongoUrl` | MongoDB connection string |
| `portalUrl` | Public URL for your Rocket.Chat instance |
| `App.id` | App identifier for mobile integration |
| `App.name` | Display name |
| `Accounts.DisableSignup` | Allow or disable new user registration |
| `LoginMethods` | Supported login methods (email, password, SSO) |
| `Notifications.Email` | Email notification settings |
| `Push.Production.APNs` | Apple Push Notification service config |
| `Push.Production.FCM` | Firebase Cloud Messaging config |
| `Theme.ColorPrimary` | Primary color theme |

### Database Setup

| System | Commands |
|--------|----------|
| MongoDB | `mongosh --eval "db = db.getSiblingDB('rocketchat'); db.createUser({user: 'rocketchat', pwd: 'password', roles: [{role: 'readWrite', db: 'rocketchat'}]});"` |

### File Locations

| System | Config Path |
|--------|-------------|
| Linux | `/etc/rocketchat/settings.json` |
| Windows | `C:\Rocket.Chat\settings.json` |

### Reloading/Restarting

```bash
# systemd
systemctl restart rocketchat

# OpenRC
rc-service rocketchat restart

# Windows (NSSM)
nssm restart rocketchat
```