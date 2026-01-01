# Security Policy

## Supported Versions

The following versions of SmartInfiniteYield are currently supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.2.x   | :white_check_mark: |
| 1.1.x   | :x:                |
| 1.0.x   | :x:                |

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
| **Critical** | Remote code execution, data theft | Immediate |
| **High** | Privilege escalation, significant data exposure | 1-3 days |
| **Medium** | Limited data exposure, DoS | 1-2 weeks |
| **Low** | Minor issues, hardening | Next release |

## Security Considerations

### API Security

- The script communicates with external AI services
- API endpoints are protected by Cloudflare
- No sensitive user data is transmitted
- All requests use HTTPS

### Local Storage

- Command cache is stored locally on the user's device
- Cache files contain only command mappings, no personal data
- Users can clear cache at any time with `clearcache`

### Executor Compatibility

- The script requires executor-level permissions
- It does not request or store credentials
- It does not modify game files or Roblox installation

## Best Practices for Users

1. **Use trusted executors** from reputable sources
2. **Keep your executor updated** to the latest version
3. **Don't share your cache files** with others
4. **Report suspicious behavior** immediately

## Acknowledgments

We appreciate security researchers who help keep SmartInfiniteYield safe. Responsible disclosure will be acknowledged in our changelog and credits.

---

*This security policy is subject to change. Last updated: January 2026*
