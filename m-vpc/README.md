# aws-vpc module

This repo contains a to deploy an aws' vpc with options common to most applications. Additonally, the variables.tf file exposes a number of options which someone using this module can alter many default settings to match requirements of a given project.

### A note on networking.

By default this module will generate 9 subnets split among 3 networking layers spread across up to 3 availability zones. It is set up to handle changes to this networking model, allowing the user to specify between 0 and 9 subnets in each layer without having to mess with renumbering the subnetting of each layer. This is accomplished by assigning each subnet a `/21` with 2046 address in. In conjunction with that subnet sizing, the layers are assigned as follows:

`Public 10.0.x.x/21`

|      az-a |      az-b |      az-c |
|----------:|----------:|----------:|
|       0.0 |       8.0 |      16.0 |
|      24.0 |      32.0 |      40.0 |
|      48.0 |      56.0 |      64.0 |

`Private 10.0.x.x/21`

|      az-a |      az-b |      az-c |
|----------:|----------:|----------:|
|      72.0 |      80.0 |      88.0 |
|      96.0 |     104.0 |     112.0 |
|     120.0 |     128.0 |     136.0 |

`Isolated 10.0.x.x/21`

|      az-a |      az-b |      az-c |
|----------:|----------:|----------:|
|     144.0 |     152.0 |     160.0 |
|     168.0 |     176.0 |     184.0 |
|     192.0 |     200.0 |     208.0 |

Whether three, nine, or no subnets are deployed for each layer, the network will retain the above basic structure unless a cidr block outside of the `/16` is used or the `newbits` variable is changed. That is to say for example, the first subnet in the isolated layer will always be `x.x.144.0/21`; the eigth assigned subnet in the same layer will always be `x.x.200.0/21`.