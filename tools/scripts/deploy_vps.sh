#!/usr/bin/env bash

rsync -vrupthlgo --delete --no-whole-file --bwlimit=150 --exclude='venv/' --exclude='.venv/' --exclude='android/' --exclude='build/' --exclude='__pycache__' -e 'sshpass -e ssh' /home/hugo/Documents/LAPAN/dev/survey/* root@72.61.60.27:/root/survey/
rsync -vrupthlgo -e 'sshpass -e ssh' /home/hugo/Documents/LAPAN/dev/survey/.env root@72.61.60.27:/root/survey/.env
sshpass -e ssh root@72.61.60.27 "cp /root/survey/docker-compose.vps.yml /root/survey/docker-compose.yml && cd /root/survey && docker compose down && docker compose up -d --build"
