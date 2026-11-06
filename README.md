# aind

## Overview

Qualitative researchers must maintain familiarity with **lots** of data over extended time periods. Anki, a spaced repetition system, may allow researchers to maintain familiarity with minimal review. Anki schedules review optimally: facts are reviewed right before they are forgotten. Retaining a single fact for 5 years costs only ~5 minutes. I estimate that retaining an hour-long interview for 5 years costs ~10 hours: 2 hours for encoding and 8 hours for review.

Despite these benefits, data security and privacy concerns prevent researchers from using Anki. Anki in Docker (`aind`) addresses these common concerns:
1. `aind` prevents accidental sharing of data over the Internet. 
2. `aind` stores data in encrypted, password-protected folders.
3. `aind` prevents accidentally saving unencrypted data.

`aind` provides a stronger security and privacy posture than storing and accessing data through Google Drive. 

## Installation

### Linux

1. Install [Docker Engine](https://docs.docker.com/engine/install/ubuntu/).
2. Download or clone this repository.

### Mac

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
2. Download or clone this repository.

### Windows

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
2. Download or clone this repository.

## Usage

The first time you run `aind`, you'll be asked to choose a password. **Remember your password**. Accessing your data is **impossible** without the password. 

### Linux

To start `aind`, run:
```bash
./start.sh
```
and enter your password. If you have a desktop open, an Anki window will appear. Otherwise, `aind` will print a URL: open it. 

To stop `aind`, quit Anki.

### Mac
To start `aind`, run:
```bash
./start.sh
```
enter your password, and open the printed URL.

To stop `aind`, quit Anki.

### Windows
To start `aind`, run:
```bash
./start.ps1
```
enter your password, and open the printed URL.

To stop `aind`, quit Anki.

# Advanced

## Backups

To backup your data, quit `aind` and copy the `encrypted-volume` folder to another drive. **Never share `encrypted-volume` publicly.** 

## Troubleshooting

Set `DEBUG=1` environment variable to display suppressed logs.

## Security

`aind` is secure against accidental data leakage and unsophisticated attackers. However, several attack vectors exist, including:
1. Supply chain attacks with container escape
2. Malicious cards with container escape
3. Local machine access (hot)

Although these attack vectors require significant expertise, frontier AI systems may allow unsophisticated actors to conduct such attacks. Personally, I wouldn't worry about it: at this threat level, ~all of your sofware is vulnerable.
