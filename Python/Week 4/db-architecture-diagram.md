# FinTrust Bank — 7-Layer Database Architecture

FinTrust's original on-premises setup was a single flat-file NAS export feeding
one general-purpose database. Over Week 4, that was replaced with seven
purpose-built AWS database services — each chosen for the specific data
model and access pattern it serves, not because it's "the best" database in
the abstract.

| Layer | Service | Region(s) | Why This Service |
|-------|---------|-----------|-------------------|
| L1 — Core transactions | RDS PostgreSQL Multi-AZ | af-south-1 (primary + standby AZ) | ACID compliance is non-negotiable for account balances and transfers; Multi-AZ gives automatic failover in 60-120s with zero connection-string change, since the standby shares the same DNS endpoint. |
| L2 — Reporting/analytics reads | Aurora PostgreSQL Read Replica | af-south-1 | Offloads read-heavy reporting queries from the primary without touching it. Aurora's 6-copies-across-3-AZs shared storage means the replica has effectively zero replication lag — it isn't a stale copy, it's reading the same underlying data. |
| L3 — Session tokens | DynamoDB Global Tables | af-south-1 + eu-west-1 | Login sessions need sub-millisecond key-value reads at unpredictable volume (login spikes). Global Tables is the only AWS database offering active-active writes in both Regions simultaneously — a session created in Cape Town is immediately valid in London with no re-authentication. |
| L4 — Regulatory audit ledger | Amazon QLDB | af-south-1 | Regulators require mathematical proof that transaction history was never altered. QLDB's append-only journal with SHA-256/Merkle-tree verification gives that proof natively — a locked RDS table can be unlocked by an administrator; QLDB's history genuinely cannot be rewritten. |
| L5 — Trade confirmation documents | Amazon DocumentDB | af-south-1 | Trade documents (equity, bond, FX, derivative) have different fields per type — a rigid relational schema would need constant migrations. DocumentDB's MongoDB-compatible flexible schema handles this natively, and the front-office team's existing MongoDB driver needs no code changes. |
| L6 — Homepage rates cache | ElastiCache Redis | af-south-1 | FX rate leaderboards need Redis's sorted-set data structure specifically (not available in Memcached), plus persistence and Multi-AZ failover so a cache-node restart doesn't wipe session-adjacent data. Memcached would fail all three requirements. |
| L7 — 5-year historical analytics | Amazon Redshift | af-south-1 | CFO-level BI queries scan hundreds of millions of rows across years of history. Redshift's columnar storage + MPP architecture makes these aggregate queries orders of magnitude faster than running them against an OLTP-optimised RDS instance — and Redshift Spectrum can query older data straight from S3 without loading it in. |

## Migration Path