# Install git packages.
git:
  pkg:
    - installed

# Clone repository into /opt/logger.
logger:
  git.latest:
    - name: https://github.com/armaduarte/super-duper-funicular.git
    - target: /opt/logger

# Add logger.sh to the cron so it can run each 30 minutes.
cron:
  cron.present:
    - name: /opt/logger/logger.sh
    - identifier: LOGGER-30
    - user: root
    - minute: '*/30'
