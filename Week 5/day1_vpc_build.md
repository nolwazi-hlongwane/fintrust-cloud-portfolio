# Week 5 Day 1 — FinTrust Multi-AZ VPC Build

## VPC CIDR Table

| Resource | Name | CIDR | AZ |
|----------|------|------|-----|
| VPC | fintrust-vpc | 10.0.0.0/16 | af-south-1 (regional) |
| Public Subnet | fintrust-public-1a | 10.0.0.0/24 | af-south-1a |
| Public Subnet | fintrust-public-1b | 10.0.1.0/24 | af-south-1b |
| App Subnet | fintrust-app-1a | 10.0.10.0/24 | af-south-1a |
| App Subnet | fintrust-app-1b | 10.0.11.0/24 | af-south-1b |
| Data Subnet | fintrust-data-1a | 10.0.20.0/24 | af-south-1a |
| Data Subnet | fintrust-data-1b | 10.0.21.0/24 | af-south-1b |

**Gateways:** 1 Internet Gateway (`fintrust-igw`, attached to the VPC — IGWs are
regional, not AZ-scoped). 2 NAT Gateways, one per AZ (`fintrust-nat-1a` in
`fintrust-public-1a`, `fintrust-nat-1b` in `fintrust-public-1b`) — each with
its own Elastic IP, since a NAT Gateway is AZ-scoped and a single shared NAT
Gateway would make every private subnet dependent on one AZ staying healthy.

## Security Group Rule Logic

| SG | Inbound Rule | Why |
|----|-------------|-----|
| `alb-sg` | 443 from `0.0.0.0/0` | The load balancer is the only thing meant to face the public internet directly — everything behind it is reached only through it. |
| `app-sg` | 8080 from `alb-sg` (SG reference, not a CIDR) | Referencing the SG rather than an IP range means only resources that are actually members of `alb-sg` can reach this tier — if the ALB's IP changed, a CIDR-based rule would silently break; an SG reference doesn't. |
| `db-sg` | 5432 (PostgreSQL) / 6379 (Redis) / 27017 (MongoDB) from `app-sg` | Same SG-reference logic — the database tier only trusts traffic that originates from something in the app tier's security group, never from the internet or the ALB directly. |

Each tier only accepts traffic from the tier immediately above it. No tier
accepts traffic from the internet except `alb-sg`, and nothing below the ALB
has a public IP at all.

## Security Group vs NACL Design Challenge

| # | Requirement | Answer | Why |
|---|-------------|--------|-----|
| 1 | Block all traffic from `41.0.0.0/8` from reaching the app subnet | **NACL DENY rule** on the app subnet | Security Groups can only ALLOW — they have no DENY capability at all. Explicitly blocking a CIDR range requires a NACL, evaluated at the subnet boundary before traffic ever reaches an instance's Security Group. |
| 2 | Allow the ALB to forward requests on port 8080 to ECS tasks | **Security Group rule** on `app-sg`: allow inbound 8080 from `alb-sg` | This is resource-level, stateful, and identity-based (SG reference) rather than IP-based — exactly what Security Groups are built for. |
| 3 | Database tier must only accept connections from the app tier | **Security Group rule** on `db-sg`: allow from `app-sg` only | Referencing `app-sg` as the source (not a CIDR block) means the rule tracks *identity* — any resource that's a member of `app-sg` qualifies, regardless of its IP address, which is more robust than hardcoding IP ranges that could change. |

## NACL Statelessness Extension

Adding a NACL inbound ALLOW rule for port 80 without a matching outbound rule
means: the server receives the request and processes it, but the **response
never leaves the subnet** — NACLs are stateless, so return traffic is a
completely separate rule evaluation, not an automatic consequence of the
inbound rule (unlike a Security Group, which is stateful and handles this
automatically). The fix is an explicit outbound ALLOW rule for the
**ephemeral port range 1024–65535**, since that's the range client
applications use for the return leg of the TCP connection.

## Group Debrief Answers

**If the af-south-1a NAT Gateway fails, which resources lose internet access?**
Only the private subnets routed to `fintrust-nat-1a` — that's `app-1a` and
`data-1a`. Subnets in `af-south-1b` (`app-1b`, `data-1b`) are unaffected,
because they route to `fintrust-nat-1b`, a completely separate NAT Gateway in
a different AZ. This is exactly why one NAT Gateway per AZ, not one shared
NAT Gateway, is the correct HA design.

**If I deploy an EC2 instance with a public IP in `fintrust-public-1a`, can the internet reach it?**
Only if all three conditions hold simultaneously: the IGW is attached to the
VPC (it is), the subnet's route table points `0.0.0.0/0` to the IGW (it
does, since it's the public route table), and the instance's Security Group
allows the relevant inbound port from `0.0.0.0/0`. A public IP alone is not
sufficient — if the Security Group doesn't permit the traffic, having a
public IP and the right route table still won't let the internet in.

**Why does `db-sg` reference `app-sg` as its source, rather than the CIDR of the app subnets?**
An SG reference tracks *group membership*, not location. If the app tier
later expands into a new subnet or a new AZ, any new instance added to
`app-sg` is automatically trusted by `db-sg` with zero additional
configuration. A CIDR-based rule would need to be manually updated every
time the app tier's IP range changed or expanded — the SG reference is
self-maintaining.

## Individual Reflection

**Traffic path — internet request to an ECS task in the app subnet:**
A user's HTTPS request hits the ALB in `fintrust-public-1a` or `-1b` (reachable
because the subnet's route table sends `0.0.0.0/0` to the IGW, and `alb-sg`
allows inbound 443 from anywhere). The ALB terminates TLS and forwards the
request over port 8080 to an ECS task running in `fintrust-app-1a` or `-1b` —
this hop is allowed because `app-sg` explicitly trusts inbound 8080 from
`alb-sg`. The ECS task itself has no public IP and no route to the internet
inbound; if it needs outbound internet access (e.g. pulling a container
image), that goes out via the NAT Gateway in its own AZ, never via the IGW
directly.

**Difference between associating a subnet with the public vs private route table:**
The public route table has a `0.0.0.0/0 → IGW` route, so anything in that
subnet *can* be reached directly from the internet if it also has a public
IP and a permissive Security Group. The private route table has no route to
the IGW at all — instead it routes `0.0.0.0/0` to a NAT Gateway, so
resources can *initiate* outbound connections but can never be *reached*
from outside. Putting a database in the wrong route table by mistake would
make it internet-routable, which is exactly the kind of misconfiguration
that turns "should be private" into a real security incident.

**One thing that surprised me about VPC networking today:**
How easy it would be to accidentally associate
a private subnet with the public route table by mistake.