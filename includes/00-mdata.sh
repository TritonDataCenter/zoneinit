#!/usr/bin/env bash
# Copyright (c) 2017, Joyent, Inc.

log 'waiting for metadata to show up'
/usr/vm/sbin/filewait /.zonecontrol/metadata.sock
