# aind

## Overview

Qualitative researchers must maintain familiarity with **lots** of data over extended time periods. Anki, a spaced repetition system, may allow researchers to maintain familiarity with minimal review. Anki schedules review optimally: facts are reviewed right before they are forgotten. Retaining a single fact for 5 years costs only ~5 minutes. I estimate that retaining an hour-long interview for 5 years costs ~10 hours: 2 hours for encoding and 8 hours for review.

Despite these benefits, data security and privacy concerns prevent researchers from using Anki. Anki in Docker (`aind`) addresses these common concerns:
1. `aind` prevents accidental sharing of data over the Internet. 
2. `aind` stores data in encrypted, password-protected folders.
3. `aind` prevents accidentally saving unencrypted data.

`aind` provides a stronger security and privacy posture than storing and accessing data through Google Drive. 

## Installation

TODO
1. Install Docker: [Docker Desktop](https://www.docker.com/products/docker-desktop/) on Mac/Windows, or Docker Engine on Linux.
2. Download or clone this repo. No build step needed.

## Usage

The first time you run `aind`, you'll be asked to choose a password. **Remember your password**. Accessing your data is **impossible** without the password. 

### Linux

To start `aind`, run:
```bash
./start.sh
```
and enter your password. If you have a desktop open, an Anki window will appear. Otherwise, `aind` will print a URL: open it. 

To stop `aind`, quit Anki and run:
```bash
./stop.sh
```

### Mac
To start `aind`, run:
```bash
./start.sh
```
enter your password, and open the printed URL.

To stop `aind`, quit Anki and run:
```bash
./stop.sh
```

### Windows
To start `aind`, run:
```bash
./start.ps1
```
enter your password, and open the printed URL.

To stop `aind`, quit Anki and run:
```bash
./stop.ps1
```

## Security

- Your Anki data is encrypted on disk. Only you, with your password, can read it.
- The app has no internet access — or, for the browser view, only a connection to your own machine — so it can't send your data anywhere.
- An earlier version of this setup could have accidentally recorded your password's secret recovery key in the logs. That's fixed.
- The browser view itself isn't password-protected, though it's only reachable from your own machine, and there are a couple of other minor hardening gaps. Ask if you'd like the full technical details.
