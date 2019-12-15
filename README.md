# Info
This site is about ... 

#### Installing
  1. Clone the docker `git clone https://github.com/phucwan91/docker infra`
  2. Run `make-init`
  3. Start docker containers `make docker-start`
  4. Install composer and node dependencies, `make site-install`
  5. Initialize database with fixture `make site-data-reset`
  6. Add the line `127.0.0.1 yoursite.localdev` to the file `/etc/hosts`
