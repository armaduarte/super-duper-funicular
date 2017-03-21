# super-duper-funicular

### Steps to reproduce the results.

#### Installing the Salt Master and Minion servers.

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
