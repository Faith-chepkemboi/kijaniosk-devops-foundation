
# Cloud Service Model - KijaniKiosk Platform

## Choice: IaaS (AWS EC2, VPC, S3)

KijaniKiosk is an early-stage online kiosk platform. We chose **IaaS** because the team needs to learn and control infrastructure before scaling to real customers.

- **IaaS:** EC2 for app, VPC for network, S3 for product images. We manage OS, Docker, security. High control, best for learning DevOps foundations.
- **PaaS (not chosen now):** Elastic Beanstalk would hide VPC/subnet learning. We will use PaaS later for RDS (managed DB) when customers grow.
- **SaaS (supporting only):** GitHub for code, but not for KijaniKiosk platform itself.

**Why IaaS for KijaniKiosk now?**
Flow: Full control of pipeline. Feedback: We can see logs/metrics directly. Learning: Team understands IAM, subnets before platform grows.
