# Security Policy

## Supported Versions

The following versions of SmartInfiniteYield are currently supported with security updates:

| Version | Supported |
| ------- | ------------------ |
| 1.3.x | :white_check_mark: |
| 1.2.x | :warning: (Limited) |
| 1.1.x | :x: |
| 1.0.x | :x: |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability, please report it responsibly.

### How to Report

**Do NOT open a public issue for security vulnerabilities.**

Instead, please report security issues by:

1. **Email:** Contact the maintainer directly through GitHub
2. **Private Issue:** If available, use GitHub's private vulnerability reporting feature

### What to Include

When reporting a vulnerability, please include:

- **Description** of the vulnerability
- **Steps to reproduce** the issue
- **Potential impact** of the vulnerability
- **Suggested fix** (if you have one)
- **Your contact information** for follow-up

### Response Timeline

| Action | Timeline |
|--------|----------|
| Initial response | Within 48 hours |
| Status update | Within 7 days |
| Fix development | Depends on severity |
| Public disclosure | After fix is released |

### Severity Levels

| Level | Description | Response Time |
|-------|-------------|---------------|
| **Critical** | Remote code execution, unauthorized file access | Immediate |
| **High** | Privilege escalation, significant data exposure | 1-3 days |
| **Medium** | Limited data exposure, DoS | 1-2 weeks |
| **Low** | Minor issues, hardening | Next release |

## Security Features & Considerations

### 🛡️ Input Sanitization (New in v1.2)

- **Sanitization Layer**: All user input strips control characters and dangerous Lua patterns before processing.
- **Injection Protection**: Prevents malicious code injection through command arguments.

### 🔒 Isolation & Privacy

- **Namespace Isolation**: Global variables use a dedicated `SmartInfiniteYield` namespace to prevent conflicts and pollution of the global environment.
- **Local Execution**: 400+ commands execute locally without ever contacting the API.
- **Token Privacy**: API Keys (if used) are sent via secure Bearer headers and are never logged or exposed in chat.

### ☁️ API Security

- **Cloudflare Protection**: API endpoints are protected by Cloudflare against DDoS and abuse.
- **HTTPS Only**: All communication uses encrypted HTTPS/TLS 1.2+ connections.
- **No Personal Data**: The script sends only game context (e.g., "Player list", "Game Genre") to the AI. No personal identifiers or chat logs are stored permanently.

### 💾 Local Storage

- **Command Cache**: Stored locally in `SIY_CommandCache.json`. Contains only command mappings (e.g., "fly" -> ";fly"), no sensitive data.
- **Clearable**: Users can wipe all local data anytime using the `;clearcache` command.

### ⚠️ Executor Compatibility

- **Permissions**: Requires standard executor permissions (`http_request`, `writefile`, `readfile`).
- **Safety**: Does not modify game files or the Roblox client installation.

## Best Practices for Users

1. **Use Trusted Executors**: Only run scripts on executors you trust.
2. **Keep Updated**: Update to the latest version (v1.3.x) for the latest security patches.
3. **Protect Your Cache**: Do not share your `workspace` folder or `SIY_CommandCache.json` file.
4. **Report Anomalies**: If the AI suggests suspicious commands, report it immediately.

## Acknowledgments

We appreciate security researchers who help keep SmartInfiniteYield safe. Responsible disclosure will be acknowledged in our changelog and credits.

---

*This security policy is subject to change. Last updated: January 12, 2026*
