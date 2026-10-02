# redis-cytaweb-test-v6

Σημαντικές επιλογές όπως ορίζονται στο `main(7).bicep`.

| Επιλογή | Τιμή |
| --- | --- |
| Τύπος resource | Azure Cache for Redis (`Microsoft.Cache/Redis`, API `2025-08-01-preview`) |
| Region | West Europe |
| Environment / criticality | test / low |
| Workload | portal |
| Redis version | 6.0 |
| SKU | Standard, family C, capacity 1 |
| TLS | Υποχρεωτικό, ελάχιστη έκδοση 1.2 |
| Non-TLS port | Απενεργοποιημένο |
| Public network access | Απενεργοποιημένο |
| Access-key authentication | Ενεργό |
| Zone allocation | NoZones |
| Update channel | Stable |
| Private Endpoint connection | Approved |

## Capacity και eviction

- `maxclients`: 1,000
- Memory reservations: `maxmemory-reserved`, `maxfragmentationmemory-reserved` και `maxmemory-delta` = 125 MB.
- `maxmemory-policy`: `volatile-lru`.

## Data access policies

Ορίζονται οι built-in access policies **Data Contributor**, **Data Owner** και **Data Reader**. Η πρώτη αφαιρεί dangerous commands, η δεύτερη δίνει πλήρη δικαιώματα και η τρίτη είναι read/connection-oriented με περιορισμένες client commands.

## Προτεινόμενη αντικατάσταση με Azure Managed Redis

| Επιλογή target | Πρόταση |
| --- | --- |
| Όνομα | `redis-cytaweb-test-v6-amr-we-01` |
| Region και tier | West Europe, Balanced B1 |
| Availability | Non-HA, μόνο εφόσον το Test data είναι rehydratable |
| Cluster policy | OSS clustering, μετά από επιβεβαίωση ότι ο client υποστηρίζει `MOVED` redirects |
| Network | Private Endpoint, private DNS zone συνδεδεμένη στα test workload VNets και χωρίς public access |
| Transport | TLS στο port 10000 |
| Authentication | Microsoft Entra ID / managed identity όπου υποστηρίζεται· access key μόνο προσωρινά για compatibility |
| Modules και persistence | Disabled initially, εκτός αν τεκμηριωθεί use case πριν το create |

1. Επιβεβαιώνουμε peak `used_memory`, evictions, key count και TTL distribution πριν οριστικοποιηθεί το B1.
2. Δημιουργούμε το AMR, Private Endpoint και DNS link, και δοκιμάζουμε TLS/authentication από κάθε Test workload.
3. Για rehydratable cache χρησιμοποιούμε cold start με controlled cache warming. Για stateful data εφαρμόζουμε dual write ή programmatic copy με cluster-aware, TLS-capable tool.
4. Ελέγχουμε Redis 7.4 compatibility, database-0-only usage, `MOVED`/`CROSSSLOT`, Lua, reconnect και keyspace-event dependencies.
5. Κάνουμε count/sample/TTL reconciliation, αλλάζουμε το application hostname στο νέο AMR endpoint και διατηρούμε το source ως rollback μέχρι να περάσει η περίοδος παρακολούθησης.