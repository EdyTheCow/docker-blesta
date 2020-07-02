# About
There’s a lack of information about setting up and running Blesta inside docker using Traefik as reverse proxy. This guide focuses on the fastest and easiest way to do that! The blesta services inside container are ran by a non root user making this setup production friendly. 

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
| DOMAIN | example.com | Enter a domain that is behind CloudFlare, this is going to be used to access blesta. You can use a domain with subdomain if you want to. |
| CF_API_EMAIL | your@email.com | Your CloudFlare's account email |
| CF_API_KEY | - | Go to your CloudFlare's profile and navigate to "API Tokens". Copy the "Global API Key" |
| MYSQL_ROOT_PASSWORD | - | Use a password generator to create a strong password |
| MYSQL_PASSWORD | - | Don't reuse your root's password for this, generate a new one |

### Starting up services
Navigate to data folder and create a directory called `blesta`. Inside `blesta` directory  create `html` and `uploads` directories. We have to manually create them because docker creates volumes using root by default. Make sure `blesta` directory is owned by user with `1000` GID and UID. You can do this by executing `sudo chown -R 1000:1000 blesta`.

Blesta is running a non-root user `nobody` using `1000` UID and GID to match host's user IDs for security reasons. If your prefered host user is using different GID and UID please refer to FAQ below to see how you can change UID and GID of user inside container.

<b>Start containers</b><br />
```
docker-compose up -d
```

You can now navigate to the DOMAIN you specified earlier to access blesta to start setting it up.

### Setting up blesta
<b>NOTE:</b> Before setting up MySQL make sure to wait at least 2 minutes from initial start up of containers. MariaDB can take a bit to initialize when started for the first time! 

Once you navigate to blesta in your web browser, you should be asked to enter MySQL details. For hostname use `db`. For username and database use `blesta` and for password use `MYSQL_PASSWORD` you set earlier. Once blesta is done generating tables, you should be asked to create your first user to access blesta!

# FAQ
### What is UID and GID?
UID stands for user id and gid is for group id. These are your linux user and group ids. To see your current user's ids use `id` command. To look up a specific user use `id username`.
### How to change UID and GID of the user inside container?
The reason why you would want to change these IDs is if you prefer a host user with different UID and GID other than 1000 to own the volumes. You can achieve this by editing Dockerfile and changing GID and UID to whatever ID you prefer. Then building the image using `docker build . -t blesta`. Make sure to change the image in `docker-compose.yml` to whatever you tag with it. In this case `blesta`

# Known issues
- Two-Factor protection doesn't work, once setup you're unable to login even if the generated code is correct. The issue might be related to Traefik.
- Changing default theme's colors doesn't work, this is related to how nginx is handling rewrite. Should be fixed soon.
