#!/usr/bin/python3
import sys
import yaml

if(len(sys.argv) != 2):
    print("Usage: %s <yaml-file>" % sys.argv[0])
    sys.exit(1)

with open(sys.argv[1]) as stream:
    try:
        data = yaml.safe_load(stream)
    except yaml.YAMLError as exc:
        print(exc)

yamldata = yaml.dump(data)
if('lookup' in yamldata or 'alias' in yamldata):
    print("Be careful with quotes. Use double-quotes within single-quotes.")
    print("Not: \"%{alias('profile::networks::storage::vlanid')}\"")
    print("But: '%{alias(\"profile::networks::storage::vlanid\")}'")

with open(sys.argv[1], 'w') as stream:
    stream.write(yaml.dump(data))
