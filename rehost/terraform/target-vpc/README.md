# Migration Server

## AWS Target VPC
- 1 AWS Region (eu-central-1)
- 1 AWS VPC (10.0.16.0/20)
- 1 AWS Public Subnet (10.0.16.0/24)
- 1 AWS Application Private Subnet (10.0.24.0/25)
- 1 AWS Database Private Subnet (10.0.24.128/25)
- 1 AWS Staging Area Private Subnet (10.0.25.0/25)
- 2 Security Groups (Inbound 80, 443 and 22 for Webserver and 5432, 22 for Database server)
  The Database SG accepts connections only from the Webserver SG
- Internet Gateway
- Nat Gateway
AWS MGN
  [x] Service is initialised and no errors show up on the console.
  [x] Create a replication template.
