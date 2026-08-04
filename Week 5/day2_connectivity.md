# Week 5 Day 2 — ALB Path-Based Routing & Connectivity Design

## ALB Configuration Notes

**Load balancer:** `fintrust-alb` — Application Load Balancer, Internet-facing,
deployed across both public subnets (`fintrust-public-1a`, `fintrust-public-1b`),
using `alb-sg` (443/80 from `0.0.0.0/0`).

**Why ALB, not NLB?** The requirement is routing based on URL *path*
(`/api/*` vs `/portal/*`), which means the load balancer needs to read HTTP
request content. That's a Layer 7 capability — NLB operates at Layer 4 and
only sees IP/port/protocol, it cannot inspect a URL path at all. If I'd tried
to use NLB here, all traffic would land on a single target group regardless
of the path, because NLB has no concept of "path" in the first place.

**Listener rules (evaluated in order, first match wins):**

| Priority | Condition | Action | Target Group |
|----------|-----------|--------|---------------|
| 1 | Path is `/api/*` | Forward | `api-targets` (port 8080) |
| 2 | Path is `/portal/*` | Forward | `portal-targets` (port 8080) |
| Default | Everything else | Forward | `portal-targets` (fallback) |

**Target groups:**
- `api-targets` — health check `/api/health`
- `portal-targets` — health check `/portal/health`

## Connectivity Design Worksheet

| Requirement | Chosen Service | Justification |
|---|---|---|
| Connect `fintrust-prod-vpc`, `fintrust-dev-vpc`, and `fintrust-audit-vpc` with centralised routing and shared internet egress | **AWS Transit Gateway** | 3+ VPCs needing centralised, transitive routing is exactly Transit Gateway's design case — each VPC attaches once to the hub, and the hub handles routing between all of them without needing a direct connection between every pair. |
| Audit VPC needs private access to a third-party compliance SaaS API, without exposing FinTrust's VPC to the internet | **AWS PrivateLink** | This is access to a *specific service*, not full network-level VPC-to-VPC connectivity. PrivateLink creates a private endpoint for just that API, with no route table changes and no inbound exposure of FinTrust's VPC at all. |
| Connect the on-premises mainframe to the prod VPC — regulatory requirement for dedicated private link, consistent sub-10ms latency, no public internet | **AWS Direct Connect** | Site-to-Site VPN was eliminated because it still routes over the public internet, which can't guarantee consistent sub-10ms latency. Direct Connect is a dedicated physical connection at a colocation facility that bypasses the internet entirely — the only option that can meet a hard regulatory latency guarantee. |
| 10 remote DevOps engineers need to access the dev VPC from their laptops for debugging | **AWS Client VPN** | This is individual end-user remote access, not site-to-site connectivity. Client VPN is purpose-built for exactly this — each engineer connects individually from their laptop, which is a completely different problem from connecting two networks together. |

### Extension — Why not VPC Peering instead of Transit Gateway?

Two reasons VPC Peering doesn't work for the 3-VPC scenario:

1. **No transitive routing.** If `prod` peers with a shared-egress VPC, and
   `dev` also peers with that same shared-egress VPC, `prod` still cannot
   reach `dev` through it — peering is strictly point-to-point. Every VPC
   pair that needs to talk to each other needs its own direct peering
   connection.
2. **Connection count explodes with scale.** Three VPCs needing full
   connectivity would require 3 separate peering connections (prod↔dev,
   dev↔audit, prod↔audit). A fourth VPC added later would push that to 6
   connections. Transit Gateway keeps this at one attachment per VPC
   regardless of how many VPCs join — the hub absorbs the complexity
   instead of the connection count growing combinatorially.

## Discussion Questions

**When does a new VPC's default route table already have a "local" route, and what does it cover?**
Every VPC gets a `local` route automatically the moment it's created — it
covers the VPC's entire CIDR block (e.g. `10.0.0.0/16`) and cannot be removed.
This is what lets any two subnets *inside* the same VPC talk to each other by
default, before you've added a single Internet Gateway, NAT Gateway, or peering
connection. It's the baseline connectivity that exists prior to any of the
routing decisions this week focused on.

**What happens to a request hitting `/payments/*` (no rule defined for it)?**
It falls through to the **default rule**, since no listener rule matches
`/payments/*` specifically. In this build, that means it gets forwarded to
`portal-targets` — the fallback target group — even though `/payments/*`
was never explicitly intended to go there. This is exactly why rule priority
and a sensible default matter: an unhandled path doesn't error out, it
silently lands wherever the default points, which could be the wrong service
if you're not paying attention.

**If FinTrust adds a fourth VPC next quarter, how many new connections does Transit Gateway need vs VPC Peering?**
Transit Gateway needs **one** new attachment — the new VPC just joins the
existing hub, and it can immediately reach every other attached VPC through
the TGW's route table. VPC Peering would need **three** new connections (one
to each of the three existing VPCs), bringing the total mesh from 3 to 6
connections. The gap only widens as more VPCs are added — Transit Gateway
scales linearly (one attachment per VPC), Peering scales combinatorially
(roughly n×(n-1)/2 connections for n VPCs).

## Individual Reflection

**Why Direct Connect beats Site-to-Site VPN for the mainframe connection:**
Site-to-Site VPN is an encrypted tunnel, but it still travels over the public
internet — its latency is whatever the internet happens to give it at any
moment, which is fine for "quick and cheap" but fails a hard regulatory
requirement for *consistent* sub-10ms latency. Direct Connect is a dedicated
physical link straight into AWS from a colocation facility, bypassing the
public internet completely. That physical dedication is what makes the
latency predictable and auditable in a way a VPN tunnel — however well
encrypted — structurally cannot guarantee.

**Path of a `/api/transfer` request, browser to ECS container:**
The request leaves the user's browser as an HTTPS call to `fintrust-alb`'s
public DNS name. It arrives at the ALB in one of the two public subnets
(reachable because `alb-sg` allows inbound 443/80 from `0.0.0.0/0`, and the
public route table sends `0.0.0.0/0` to the IGW). The ALB's listener
evaluates its rules in priority order — `/api/*` matches before the default
rule is ever considered — and forwards the request to the `api-targets`
target group on port 8080. From there it reaches a healthy ECS task running
in one of the private app subnets (`app-1a` or `app-1b`), permitted because
`app-sg` trusts inbound 8080 specifically from `alb-sg`. The container itself
has no public IP and no inbound route from the internet at all — the ALB is
the only door in.

**Key difference between PrivateLink and VPC Peering, in terms of what traffic they expose:**
VPC Peering exposes the *entire network* — once peered, both VPCs can
potentially route to any resource in the other VPC's CIDR range, subject to
security groups and route tables. PrivateLink exposes exactly *one service*
through a private endpoint, with no visibility into or access to anything
else in the provider's VPC. Peering is a network-level relationship between
two VPCs; PrivateLink is a narrow, service-level door that doesn't require
network-level trust between the two sides at all.