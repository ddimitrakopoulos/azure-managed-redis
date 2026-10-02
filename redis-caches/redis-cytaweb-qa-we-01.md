# redis-cytaweb-qa-we-01

Σημαντικές επιλογές όπως ορίζονται στο `redis-cytaweb-qa-we-01.bicep`.

| Επιλογή | Τιμή |
| --- | --- |
| Τύπος resource | Azure Cache for Redis (`Microsoft.Cache/Redis`, API `2025-08-01-preview`) |
| Region | West Europe |
| Environment / criticality | qa / medium |
| Workload | portal |
| Redis version | 6.0 |
| SKU | Standard, family C, capacity 1 |
| TLS | Υποχρεωτικό, ελάχιστη έκδοση 1.2 |
| Non-TLS port | Απενεργοποιημένο |
| Public network access | Απενεργοποιημένο |
| Microsoft Entra authentication | Ενεργό (`aad-enabled: true`) |
| Access-key authentication | Ενεργό |
| Zone allocation | Automatic |
| Update channel | Stable |
| Private Endpoint connection | Approved |

## Capacity και eviction

- `maxclients`: 1,000
- Memory reservations: `maxmemory-reserved`, `maxfragmentationmemory-reserved` και `maxmemory-delta` = 125 MB.
- Δεν ορίζεται `maxmemory-policy`; χρησιμοποιείται η πλατφορμική προεπιλογή.

## Data access policies

Ορίζονται οι built-in access policies **Data Contributor**, **Data Owner** και **Data Reader**. Η πρώτη αφαιρεί dangerous commands, η δεύτερη δίνει πλήρη δικαιώματα και η τρίτη είναι read/connection-oriented με περιορισμένες client commands.

## Προτεινόμενη αντικατάσταση με Azure Managed Redis

| Επιλογή target | Πρόταση |
| --- | --- |
| Όνομα | `redis-cytaweb-qa-we-01-amr-we-01` |
| Region και tier | West Europe, Balanced B1 |
| Availability | HA, με zone redundancy όπου διατίθεται στην περιοχή |
| Cluster policy | OSS clustering, μετά από επιβεβαίωση ότι ο client υποστηρίζει `MOVED` redirects |
| Network | Private Endpoint, private DNS zone συνδεδεμένη στα QA workload VNets και χωρίς public access |
| Transport | TLS στο port 10000 |
| Authentication | Microsoft Entra ID / managed identity; retire the access key after client cutover |
| Modules και persistence | Disabled initially, εκτός αν τεκμηριωθεί use case πριν το create |

1. Επιβεβαιώνουμε peak `used_memory`, evictions, key count και TTL distribution. Το B1 επιβεβαιώνεται με βάση usable memory, όχι μόνο το nominal source size.
2. Δημιουργούμε το AMR με HA, Private Endpoint και DNS link, και δοκιμάζουμε TLS και Entra authentication από κάθε QA workload.
3. Για rehydratable cache χρησιμοποιούμε cold start με controlled cache warming. Για sessions, queues ή άλλο state εφαρμόζουμε idempotent dual write ή programmatic copy.
4. Ελέγχουμε Redis 7.4 compatibility, database-0-only usage, `MOVED`/`CROSSSLOT`, Lua, reconnect/failover και keyspace-event dependencies.
5. Κάνουμε count/sample/TTL reconciliation, κάνουμε cutover στο νέο hostname, και διατηρούμε το source ως rollback μέχρι την επιτυχή QA validation.