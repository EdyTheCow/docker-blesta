# About
There’s a lack of information about setting up and running Blesta inside docker using Traefik as reverse proxy. This guide focuses on the fastest and easiest way to do that! 

# Getting Started
We’ll be using docker, docker-compose and CloudFlare for DNS challenges to generate certificates. DNS challenges allow wildcard certificates allowing you to add any subdomains on the go. If you prefer using something else, have a look at [Traefik's Docs](https://docs.traefik.io/https/acme/).

### Requirements
- Basic command line knowledge
- A domain behind Cloudflare
- [Docker](https://docs.docker.com/engine/install/ubuntu/)
- [Docker Compose](https://docs.docker.com/compose/install/)

# Installation

### Basic configuration
Once you have met all of the requirements, start by cloning this repository
```
git clone https://github.com/EdyTheCow/blesta-docker.git
```

Enter the compose directory and rename `.env.example` to `.env`. The most important variables to change right now are:

| Variable | Example | Description |
|-|:-:|-|
| DOMAIN | example.com | Enter a domain that is behind CloudFlare, this is going to be used to access blesta |
| CF_API_EMAIL | your@email.com | Your CloudFlare's account email |
| CF_API_KEY | - | Go to your CloudFlare's profile and navigate to "API Tokens". Copy the "Global API Key" |
| MYSQL_ROOT_PASSWORD | - | Use a password generator to create a strong password |
| MYSQL_PASSWORD | - | Don't reuse your root's password for this, generate a new one |

### Starting up services
Navigate to data folder and create a directory called `blesta`. The blesta container is running a non root user for security reasons, as long as your user's UID and GID is 1000. You should be fine (you can check using command `id`). Otherwise check FAQ at the bottom.

<b>Start containers</b><br />
```
docker-compose up -d
```

You can now navigate to the DOMAIN you specified to access blesta and start setting it up.

### Setting up blesta
<b>NOTE:</b> Before setting up MySQL make sure to wait at least 2 minutes from initial start up of containers. MariaDB can take a bit to initialize when started for the first time! 

Once you navigate to blesta, you should be asked to enter MySQL details. For hostname use `db`. For username and database use `blesta` and for password use `MYSQL_PASSWORD` you set earlier. 

WIP
