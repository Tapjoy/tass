# Configuration Options
```yaml
:bootstrap_script:               # (String) Name of userdata script

# ELB Parameters
:default_elb_parameters:         # (Hash) Hash that holds default elb configuration parameters (as follows)
:instance_protocol:              # (String) Protocol that instance listens on
:instance_port:                  # (Int) Port number that instance listens on
:elb_health_interval:            # (Int) ELB health check interval in minutes
:elb_health_timeout:             # (Int) ELB health timeout in minutes
:elb_unhealthy_threshold:        # (Int) ELB unhealthy check limit
:elb_healthy_threshold:          # (Int) ELB health check limit
:elb_name:                       # (String) ELB name to create and join for an Autoscale Group
:elb_port:                       # (Int) Port ELB listens on
:create_elb:                     # (Boolean) Whether or not to create an ELB associated with the autoscaling group
:clobber_elb:                    # (Boolean) Whether or not to force ELB creation, clobbering existing ELB if any

# Scaling Parameters
:autoscale:                      # (Boolean) Whether or not to configure automatic autoscaling on the autoscaling group
:scale_up_cooldown:              # (Int) Time in minutes to cooldown post scaling up
:scale_up_scaling_adjustment:    # (Int) Number of servers to scale up at one time
:scale_up_threshold:             # (Int) CPU Percentage to scale up on
:scale_down_cooldown:            # (Int) Time in minutes to cooldown post scaling down
:scale_down_scaling_adjustment:  # (Int) Number of servers to scale down at one time (MUST BE < 0)
:scale_down_threshold:           # (Int) CPU Percentage to scale down on
:health_check_type:              # (String) Type of health check (MUST BE 'EC2' or 'ELB')

:environment:                    # (String) Specify which environment config to load.
:image_id:                       # (String) Image id to launch instances with (MUST START WITH ami-)
:iam_instance_profile:           # (String) IAM profile to launch instances with
:create_as_group:                # (Boolean) Whether or not to create an autoscaling group
:alerts:                         # (Boolean) Whether or not to create scaling alerts
:clobber:                        # (Boolean) Whether or not to clobber existing autoscaling group, if one exists

:aws_region:                     # (String) Region to launch AWS instances in
:tags:                           # (Hash) AWS tags to associate with autoscaling instances.  Keys are Symbols and Values are Strings
:keypair:                        # (String) Name of AWS keypair to use
:sns_base_arn:                   # (String) Base ARN to use for SNS topics/notifications takes the format of 'arn:aws:sns:<region>:<account_id>'
:zones:                          # (String Array) List of Availability Zones to use
:human_name:                     # (String) Human readable name for autoscaling group
:name:                           # (String) name for autoscaling group
:instance_type:                  # (String) Instance type to use (e.g, t2.medium)
:group:                          # (String) Comma-separated list of security groups to attach to autoscaler
:placement_group:                # (String) — The name of the placement group into which you\'ll launch your instances, if any.
:vpc_subnets:                    # (String) Comma-separated list of VPC subnets to assign to autoscaler (valid for VPC instances only)
:classic_link_vpc_id:            # (String) VPC id to use for ClassicLink (valid for EC2-Classic instances only)
:classic_link_sg_ids:            # (String Array) VPC subnets to use for ClassicLink (valid for EC2-Classic instances only)
:spot_price:                     # (String) The maximum hourly price to be paid for any Spot Instance launched to fulfill the request. (valid for spot instances only)
:termination_policies:           # (String Array) List of termination policies to apply to autoscaler (reference AWS documentation for further info)

:scaling_type:                   # (String) Type of scaling group to create.  At this time, the value should either be 'dynamic' or 'static'.
:instance_counts:                # (Int Hash) Contains the instance counts for the autoscaling group
:min:                            # (Int) Key/value pair in the instance_counts hash, lists the minimum count required for a dynamic auto scaling group
:max:                            # (Int) Key/value pair in the instance_counts hash, lists the maximum count required for a dynamic auto scaling group
:desired:                        # (Int) Key/value pair in the instance_counts hash, lists the desired instance count for an auto scaling group.  In addition to applying to dynamic groups, this is the only count that is used for static groups.
```
