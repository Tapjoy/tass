v1.0.0
==
#### Enhancement
* PR [#13](https://github.com/Tapjoy/tass/pull/13): Create a new workflow around ELBs, to allow multiple ELBs to be attached to an auto scaling group without requiring management of each ELB.
* PR [#14](https://github.com/Tapjoy/tass/pull/14): Remove $CONFIG_DIR options, now traverse the path relative to the specified config file.  Additionally, set the termination policy for the auto scaling groups to be set via config file rather than hard-coded.
* PR [#15](https://github.com/Tapjoy/tass/pull/14): Allow configurations of static and dynamic auto scaling groups.  Also, fix the specs to be more accurate to the proper code flow and reduce false errors.

v0.2.2
==
#### Enhancement
* PR [#12](https://github.com/Tapjoy/tass/pull/12): Adding support to specify a custom list of elbs for an autoscaling group to add itself to

v0.2.1
==
#### Bug Fixes
* PR [#11](https://github.com/Tapjoy/tass/pull/11): Errors creating/updating launch configurations should be fatal

v0.2.0
==
#### Enhancement
* Issue [#5](https://github.com/Tapjoy/tass/issues/5), PR [#10](https://github.com/Tapjoy/tass/pull/10): tass <action> --file should take a file path
* Properly catch error when launch configuration limit has been exceeded

v0.1.3
==
#### Enhancement
* Issue [#6](https://github.com/Tapjoy/tass/issues/6), PR [#8](https://github.com/Tapjoy/tass/pull/8): Allow environment to be specified in YAML

v0.1.2
==
#### Bug Fixes
* Issue [#4](https://github.com/Tapjoy/tass/issues/4), PR [#7](https://github.com/Tapjoy/tass/pull/7): Launch configuration name is based on current ASG launch configuration and not tass name value

v0.1.1
==
#### Bug Fixes
* PR [#2](https://github.com/Tapjoy/tass/pull/2): Allow VPC security group to be overwritten

v0.1.0
==
* Initial version made available for public consumption
