#!/bin/bash
echo "${public_key_1}" > /home/${user}/.ssh/authorized_keys
echo "${public_key_2}" >> /home/${user}/.ssh/authorized_keys
chown ${user}: /home/${user}/.ssh/authorized_keys
chmod 0600 /home/${user}/.ssh/authorized_keys