# Introduction #

Bedtime feature ([issue 8](https://code.google.com/p/mplayer-library/issues/detail?id=8)) requires a shutdown command, which requires root.


# Details #

`mplayer-library dvd; shutdown -P +10` is the current suggested workaround.

However, the shutdown command can only be run as root normally. This can be solved in two ways.

The first is running `sudo chmod u+s /sbin/shutdown` which allows any user, but this _[may be insecure](http://askubuntu.com/questions/91397/are-there-consequences-to-running-sudo-chmod-us-sbin-shutdown)_.

The second involves editing /etc/sudoers which is complicated, and quite involved, but is explained nicly [here](http://how-to.wikia.com/wiki/How_to_allow_non-super_users_to_shutdown_computer_in_Linux). This might be possible to set up in the install script, although there **should be a prompt**.