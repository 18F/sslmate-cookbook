# sslmate Cookbook

A Chef cookbook for installing the [sslmate](https://sslmate.com) command line utility. It also includes optional helper scripts for automating the purchasing, renewal, and installation of certificates in an AWS environment.

Attributes
----------

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['sslmate']['git_repository']</tt></td>
    <td>String</td>
    <td>The git URL to fetch sslmate's source code from</td>
    <td><tt>https://github.com/SSLMate/sslmate.git</tt></td>
  </tr>
  <tr>
    <td><tt>['sslmate']['git_revision']</tt></td>
    <td>String</td>
    <td>The git tag, branch, or revision to install from</td>
    <td><tt>0.6.2</tt></td>
  </tr>
  <tr>
    <td><tt>['sslmate']['prefix']</tt></td>
    <td>String</td>
    <td>The installation prefix for sslmate</td>
    <td><tt>/usr/local</tt></td>
  </tr>
  <tr>
    <td><tt>['sslmate']['domains']</tt></td>
    <td>Array</td>
    <td>A list of domains to manage the SSL certificates for with the manage_domain recipe</td>
    <td><tt>[]</tt></td>
  </tr>
</table>

## Usage

### sslmate::default

The default recipe will install sslmate from source. Simply include it in your run list:

```json
{
  "run_list": [
    "recipe[sslmate]"
  ]
}
```

### sslmate::manage_domains

The `manage_domains` recipe will install sslmate and some additional helper scripts to automate purchasing, renewing, and installing certificates in an Amazon Web Services environment (currently it assumes SSL certs will be installed in an ELB, but all this could be modified for other environments).

#### Prerequisites

- DNS should be configured for your domain. Create your hosted zone for your domain in Route 53, and make sure the domain is either registered there, or fully delegated from your registrar to Route 53.
- Currently, your SSLMate account will need to be manually activated to use DNS approval.
- It's recommended that you use a set of AWS credentials scoped to access just the things you need, rather than root credentials that could control your entire AWS account. Here's a list of IAM permissions needed:

  ```
  route53:ListHostedZones on *
  route53:GetChange on arn:aws:route53:::change/*
  route53:ListResourceRecordSets on arn:aws:route53:::hostedzone/HOSTED_ZONE_ID
  route53:ChangeResourceRecordSets on arn:aws:route53:::hostedzone/HOSTED_ZONE_ID
  iam:UploadServerCertificate on *
  elasticloadbalancing:SetLoadBalancerListenerSSLCertificate on arn:aws:elasticloadbalancing:REGION_NAME:ACCOUNT_ID:loadbalancer/LOAD_BALANCER_NAME
  ```

#### Configuration

Currently this relies on a beta version of SSLMate, so you must specify the `git_revision` (from the [`apiv2`](https://github.com/SSLMate/sslmate/tree/apiv2) branch). Specify the `domains` like this example:

```json
{
  "run_list": [
    "recipe[sslmate::manage_domains]"
  ],
  "sslmate": {
    "git_revision": "2bc1946efdf5d80d333d6cc477dd74e6c8d42663",
    "domains": [
      {
        "host": "example.com",
        "elbs": [
          {
            "region": "us-east-1",
            "name": "example-lb"
          }
        ]
      }
    ]
  }
}
```

#### Installation & Management

1. **Run chef:** To install all the necessary dependencies.
2. **First-time purchase:** To purchase a new certificate, run this helper script that gets installed by Chef for your configured domains:

  ```sh
  $ sudo /usr/local/sbin/sslmate_example.com_buy
  ```
  
  It will prompt for your SSLMate and AWS credentials the first time it's run. It will then purchase the certificate and configure the defined ELBs to use it.
3. **Tada!** That should be all that's necessary. A cron job will also get installed in `/etc/cron.daily/sslmate_example.com_auto_renew`. This will automatically download and install a new SSL certificate on a yearly basis when SSLMate renews your cert.

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
