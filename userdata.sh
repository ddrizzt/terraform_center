#!/bin/bash
rm -rf /mnt/*
cd /mnt/ && curl -H "Authorization: token e280bf479d351af3a96b887ecc764ca19bf4a165" -L https://github.com/ddrizzt/gdoawechat/archive/master.zip > wechat-oa-master.zip
cd /mnt/ && unzip wechat-oa-master.zip
mv /mnt/gdoawechat-master /mnt/wechat-oa-master
cd /mnt/wechat-oa-master && chmod +x *.sh
/mnt/wechat-oa-master/deploy_all.sh


