# Faved

A lightweight, privacy-first bookmark manager with a clean, fast UI — self-hosted on Railway.

[![Deploy to Railway](https://railway.app/button.svg)](https://railway.com/deploy/zOL7cT)

## Features

- Minimal, distraction-free bookmark management
- Tag-based organization and quick search
- Privacy-first — no telemetry, no tracking
- Self-hosted with persistent storage
- Automatic HTTPS via Railway
- Health monitoring via Railway proxy

## Configuration

| Variable | Description | Default |
|---|---|---|
| `PORT` | HTTP listen port | `80` |

## Volumes

- `/var/www/html/storage` — Persistent bookmark and tag data
- `/tmp` — Temporary cache and session data

## License

MIT — [Faved on GitHub](https://github.com/denho/faved)

## Deploy and Host

Click the Deploy to Railway button above to deploy Faved on Railway. Persistent volumes are configured automatically so your bookmarks survive redeployments.

## About Hosting

This template runs Faved on Railway, a cloud platform that handles infrastructure, scaling, and HTTPS. All bookmark data is stored on a persistent volume for durability. Railway provides automatic TLS termination and private networking between services.

## Common Use Cases

- Personal bookmark library with fast search
- Team bookmark sharing with tags
- Privacy-focused alternative to browser bookmark sync
- Read-it-later service with organizational tags

## Dependencies for

- Faved — Apache/PHP bookmark manager
- No database companion required — all data is stored on persistent volumes

### Deployment Dependencies

| Dependency | Description |
|---|---|
| Persistent volume `/var/www/html/storage` | Bookmark and tag data storage |
| Persistent volume `/tmp` | Temporary cache and session data |
| Railway account | Must have access to a single service |

## Quick Start

1. Click the Deploy to Railway button above
2. Wait for the build to complete (~2 minutes)
3. Access Faved at the deployed URL
4. Start adding bookmarks — data persists across redeployments