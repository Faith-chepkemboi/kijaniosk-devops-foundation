
# Region and AZ Design - KijaniKiosk

## Region Selection: us-east-1 for starter kit, af-south-1 for production
KijaniKiosk targets Kenyan users (Kikuyu). For learning, we use **us-east-1** (cheapest, 6 AZs, free tier). For production with real customers, we will migrate to **af-south-1 (Cape Town)** to cut latency from 250ms to ~60ms for Kenya.

## Multi-AZ Reliability for KijaniKiosk
KijaniKiosk cannot go down during sales.

Architecture:
- VPC 10.0.0.0/16 in us-east-1
- AZ-a (us-east-1a): Public Subnet 10.0.1.0/24 (ALB) + Private Subnet 10.0.2.0/24 (EC2 app)
- AZ-b (us-east-1b): Private Subnet 10.0.3.0/24 (EC2 app standby) + RDS Multi-AZ

Reliability Thinking:
1. If AZ-a fails, ALB routes to AZ-b - KijaniKiosk stays online
2. RDS Multi-AZ syncs product/orders DB across AZs
3. This blueprint prepares KijaniKiosk before real customers begin using it.
