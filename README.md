TASS
====
[![Gem Version](https://badge.fury.io/rb/tass.svg)](http://badge.fury.io/rb/tass)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/8e3b1efa8ff94817a281efd12aed3bb3)](https://www.codacy.com/app/ali-tayarani/tass?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=Tapjoy/tass&amp;utm_campaign=Badge_Grade)
[![Gem](https://img.shields.io/gem/dt/tass.svg)](https://rubygems.org/gems/tass/)
[![Build Status](https://travis-ci.org/Tapjoy/tass.svg?branch=master)](https://travis-ci.org/Tapjoy/tass)

TASS is the suite of tools that the Tapjoy Operations team uses to manage autoscaling groups and launch configurations.

## Requirements
* Ruby 2.1
* Trollop 2.1
* AWS SDK 2.0
* Hashdiff 0.2
* Highline 1.0

## Installation
### Installation from RubyGems
```
gem install tass
```
### Installation from source
```
git clone git@github.com:Tapjoy/tass.git
cd tass
gem build tass.gemspec
gem install tass*.gem --no-ri --no-rdoc
cd ..
```

## Configuration

There are several config files used for this application, broken out into a few categories:

* Environment variables
* Instance configuration
    * config/common/defaults.yaml
    * config/common/<env>.yaml
    * config/clusters/<cluster_name>.yaml
* Userdata

### Instance configuration

For information on configuration options, please reference [Configuration Options] (docs/CONFIG_OPTIONS.md)

These files are located in the config configuration directory.

#### config/common/defaults.yaml

This is the config file that loads global (i.e, not environment-specific) configuration options.

#### config/common/<env>.yaml

This config file loads environment-specific configuration options and overrides global options.

#### config/clusters/<cluster_name>.yaml

This config file loads cluster-specific configuration options and overrides all other config options.

### Userdata configuration

Userdata configuration files are ERB templates located in the userdata config directory.  These templates can have any content you need during instance bootstrap.  Additionally, if you need any variables in the template you can pass them in via any of the instance configuration config files.

## Commands
### create

This command creates new autoscaling groups, and overwrites existing ones.
NOTE: `--env` has been deprecated and will be removed in a future version

```
Usage: tass create [options]

Options:
  -f, --filename=<s>           Specify config file to load
  -e, --env=<s>                Specify which environment config to load
  --clobber-elb                Force ELB creation
  --clobber-as                 Force AS group creation
  -p, --prompt, --no-prompt    Enable/disable prompts (default: true)
  -h, --help                   Show this message
```

### update

This command creates new launch configurations based on existing autoscaling groups using local instance configuration files as overrides.
NOTE: `--env` has been deprecated and will be removed in a future version

```
Usage: tass update [options]

Options:
  -f, --filename=<s>           Specify config file to load
  -e, --env=<s>                Specify which environment config to load
  -p, --prompt, --no-prompt    Enable/disable prompts (default: true)
  -h, --help                   Show this message
```

### audit

This command compares local configuration files for a given cluster to the existing launch configuration and autoscaling group running in AWS.
NOTE: `--env` has been deprecated and will be removed in a future version

```
Usage: tass audit

Options:
  -f, --filename=<s>           Specify config file to load
  -e, --env=<s>                Specify which environment config to load
  -p, --prompt, --no-prompt    Enable/disable prompts (default: true)
  -h, --help                   Show this message
```

### scale

This command is used to scale up/down auto scaling groups
NOTE: `--env` has been deprecated and will be removed in a future version

```
Options:
  -f, --filename=<s>           Specify config file to load
  -p, --prompt, --no-prompt    Enable/disable prompts (default: true)
  -e, --env=<s>                Specify which environment config to load
  -i, --instance-ids=<s+>      Instance IDs to scale down
  -h, --help                   Show this message
```
