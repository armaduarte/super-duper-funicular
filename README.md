# super-duper-funicular

## Steps to reproduce the results.

### Installing the Salt Master and Minion servers.

1. Start a Ubuntu Linux 14.04.5 x64 Server instance and login using the username **root** and the private key sent in the e-mail. The key password has been sent in that e-mail too. The credentials (keys) setup must be done in the instance provider´s admin panel.

2. Once logged, add the SaltStack PPA repository:<br>
`sudo add-apt-repository ppa:saltstack/salt`<br>
It will ask you to confirm adding a new repository, press *ENTER* to confirm.

3. Upgrade all packages in the system:<br>
`sudo aptitude update; sudo aptitude safe-upgrade -y`

4. Install SaltStack packages (including master and minion packages):<br>
`sudo apt-get install salt-master salt-minion salt-ssh salt-cloud salt-doc -y`

5. Create SaltStack directories structures:<br>
`sudo mkdir -p /srv/{salt,pillar}`<br>

6. Modify the Salt Master configuration file (`sudo vim /etc/salt/master`) by changing the location of the configuration management instructions (*file_roots*) to point to the new location that was created in the step 5. The *file_roots* directive should looks like this:<br>
```
file_roots:
   base:
     - /srv/salt
     - /srv/formulas
```

7. Continue modifying the Salt Master configuration but this time we will change the location of the Salt pillar configuration (*pillar_roots*) to point to the new location also created in the step 5. The *pillar_roots* directive should looks like this:<br>
```
pillar_roots:
  base:
    - /srv/pillar
````

8. Modify the Salt Minion configuration file (`sudo vim /etc/salt/minion`) by changing the master IP address so the minion can find the master. Since we are running both master and minion in the same server, the IP will be the local *127.0.0.1*. The directive should looks like this:<br>
```
# Set the location of the salt master server. If the master server cannot be
# resolved, then the minion will fail to start.
master: 127.0.0.1
```

9. Restart both Salt Master and Minion services in order to apply the modifications.<br>
`service salt-master restart; service salt-minion restart`

10. Verify both Salt Master and Minion connection fingerprint in order to accept the keys so they can start "talking" to each other:<br>
`sudo salt-call key.finger --local`<br>
`sudo salt-key -f saltmaster`<br>
*PS: The server´s hostname is **mfserver**.*<br>

11. Both commands should give the same connection fingerprint, for these steps, the output was:<br>
`d7:1d:7f:93:17:f6:67:1d:e0:f9:5e:69:bf:c9:08:96`<br>
If they match, you can continue accept the key with the command:<br>
`sudo salt-key -a mfserver`<br>
And then confirming when asked.

12. You should see the key accepted when listing using the command:<br>
`sudo salt-key --list all`<br>
```
Accepted Keys:
mfserver <-------------
Denied Keys:
Unaccepted Keys:
Rejected Keys:
```

13. Do a small test the check if master and minion processes are working properly. The results of the following command should return a **True**:<br>
`sudo salt '*' test.ping`

### Applying the states.

#### The logger.sh script.

1. Clone this repository in the server. For this steps we will use the home diretory at */root*:<br>
`git clone https://github.com/armaduarte/super-duper-funicular.git`<br>

2. Change to the repository directory created after the cloning:<br>
`cd super-duper-funicular`

3. Copy the file **logger.sls** to */srv/salt/*:
`cp logger.sls /srv/salt`

4. Run the state so it can download the **logger.sh** script and setup the crontab.<br>
`state '*' state.sls logger`<br>

5. If you see this ouput below everything worked fine:<br>
```
Summary
------------
Succeeded: 3
Failed:    0
------------
Total states run:     3
```

6. The **logger.sh** script will be located at /opt/logger and the cron will execute it from there each 30 minutes. Check the crontab:<br>
`crontab -e`<br>
```
# Lines below here are managed by Salt, do not edit
# SALT_CRON_IDENTIFIER:LOGGER-30
*/30 * * * * /opt/logger/logger.sh
```

7. The report will be placed at **/root/counts.log** and each line will looks like this one:<br>
`DATETIME: Mon Mar 20 23:06:13 UTC 2017 | FILENAME: /var/log/upstart/mountall.log | NUMBER OF LINES: 2`

#### Using users-formula to grant access to three users using SSH keys.

1. Back to the repository folder, copy the pillar files **top.sls** and **users.sls** to the */srv/pillar* folder.<br>
`cd /root/super-duper-funicular; cp top.sls /srv/pillar; cp users.sls /srv/pillar`

2. Make minion refresh pillar data. A **True** output should appear:<br>
`salt '*' saltutil.refresh_pillar`

3. List all pillars to see if everything is OK:<br>
`salt '*' pillar.items`<br>
If the output is too big, you can resume it to show the name of the three users to be created meaning that pillars are ok:<br>
`salt '*' pillar.items | grep User`<br>
Output:<br>
```
root@mfserver:/srv/pillar# salt '*' pillar.items | grep User
                User A
                User B
                User C
```

4. Create a folder to hold the formulas in our server:<br>
`mkdir -p /srv/formulas`

5. We need to get the **users-formula** to use together with our pillar files. Let´s clone the github repository at the location */srv/formulas*:<br>
`cd /srv/formulas; git clone https://github.com/saltstack-formulas/users-formula.git`

6. Edit the Salt Master configuration file and add the new folder that the cloned users-formula repository created to the Master can see it. The *file_roots* directive now should looks like this:<br>
```
file_roots:
   base:
     - /srv/salt
     - /srv/formulas
     - /srv/formulas/users-formula
```
7. Restart both Salt Master and Minion services in order to apply the modifications.<br>
`service salt-master restart; service salt-minion restart`

8. Now let´s create the users running the following command:<br>
`salt '*' state.sls users`

9. If everything went ok, you should see the following output:<br>
```
Summary
-------------
Succeeded: 24
Failed:     0
-------------
Total states run:     24
```

10. Doing another check using **getent** we can see the brand new three users created:<br>
`getent passwd`<br>
```
userb:x:1000:1000:User B,,,:/home/userb:/bin/bash
userc:x:1001:1001:User C,,,:/home/userc:/bin/bash
usera:x:1002:1002:User A,,,:/home/usera:/bin/bash
```
