# CAPCI: AWS Migration Lab

## Directory Structure
The following directory structure should be maintained for this repository:
```
├── .gitignore
├── README.md
├── TEMPLATE                          Template for terraform root modules
├── rehost
    ├── terraform                 Terraform root modules
    |   ├── source-vpc            Deploy VPC for simulating on-prem data center
    |   ├── target-vpc            Deploy VPC for hosting  workload migrated to AWS
    |   ├── patch-management      Configure patch management
    |   └── automated-backups     Configure automatic backups
    |
    └── python                    Python scripts
        └── src
            ├── libs              Reusable artifacts
            └── utils             Utility components
``` 

- 1 VPC (172.16.0.0/16) with Internet Gateway and NAT Gateway
- 1 Public Subnet (172.16.10.0/24)
- 1 Private Subnet (172.16.20.0/24)
- 2 Security Groups (Inbound 80, 443 and 22 for Webserver and 5432, 22 for Database server)
- The database SG accepts connections only from the webserver SG
- 2 EC2 instances (1 in the public one for webserver and 1 in the private one for the database)
- Webserver is on t3.medium. DB on m5.large
- Postgres is configured on DB server
- PGAdmin is working on webserver and connected with the DB
- IAM User with policy AWSApplicationMigrationAgentPolicy attached
