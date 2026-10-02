# redis-cytaweb-qa

Σημαντικές επιλογές όπως ορίζονται στο `main(4).bicep`.

| Επιλογή | Τιμή |
| --- | --- |
| Τύπος resource | Azure Cache for Redis (`Microsoft.Cache/Redis`, API `2025-08-01-preview`) |
| Region | West Europe |
| Environment / criticality | qa / medium |
| Application / workload | CytaWeb / portal |
| Redis version | 6.0 |
| SKU | Standard, family C, capacity 1 |
| TLS | Υποχρεωτικό, ελάχιστη έκδοση 1.2 |
| Non-TLS port | Απενεργοποιημένο |
| Public network access | Απενεργοποιημένο |
| Access-key authentication | Ενεργό |
| Zone allocation | NoZones |
| Update channel | Stable |
| Private Endpoint connection | Approved |

## Capacity, eviction και firewall

- `maxclients`: 1,000
- Memory reservations: `maxmemory-reserved`, `maxfragmentationmemory-reserved` και `maxmemory-delta` = 21 MB.
- `maxmemory-policy`: `volatile-lru`.
- Υπάρχει firewall rule `1` για `0.0.0.0` έως `255.255.255.255`. Επειδή το `publicNetworkAccess` είναι Disabled, η rule δεν παρέχει δημόσια πρόσβαση όσο διατηρείται αυτή η ρύθμιση.

## Data access policies

Ορίζονται οι built-in access policies **Data Contributor**, **Data Owner** και **Data Reader**. Η πρώτη αφαιρεί dangerous commands, η δεύτερη δίνει πλήρη δικαιώματα και η τρίτη είναι read/connection-oriented με περιορισμένες client commands.

## Προτεινόμενη αντικατάσταση με Azure Managed Redis

| Επιλογή target | Πρόταση |
| --- | --- |
| Όνομα | `redis-cytaweb-qa-amr-we-01` |
| Region και tier | West Europe, Balanced B1 |
| Availability | HA, με zone redundancy όπου διατίθεται στην περιοχή |
| Cluster policy | OSS clustering, μετά από επιβεβαίωση ότι ο client υποστηρίζει `MOVED` redirects |
| Network | Private Endpoint, private DNS zone συνδεδεμένη στα QA workload VNets και χωρίς public access |
| Transport | TLS στο port 10000 |
| Authentication | Microsoft Entra ID / managed identity όπου υποστηρίζεται· access key μόνο προσωρινά για compatibility |
| Modules και persistence | Disabled initially, εκτός αν τεκμηριωθεί use case πριν το create |

1. Επιβεβαιώνουμε peak `used_memory`, evictions, key count και TTL distribution. Το B1 επιβεβαιώνεται με βάση usable memory, όχι μόνο το nominal source size.
2. Δημιουργούμε το AMR με HA, Private Endpoint και DNS link. Δεν μεταφέρουμε το legacy firewall rule, επειδή το AMR χρησιμοποιεί Private Link και δεν υποστηρίζει IP-based firewall rules.
3. Για rehydratable cache χρησιμοποιούμε cold start με controlled cache warming. Για sessions, queues ή άλλο state εφαρμόζουμε idempotent dual write ή programmatic copy.
4. Ελέγχουμε Redis 7.4 compatibility, database-0-only usage, `MOVED`/`CROSSSLOT`, Lua, reconnect/failover και keyspace-event dependencies.
5. Κάνουμε count/sample/TTL reconciliation, κάνουμε cutover στο νέο hostname, και διατηρούμε το source ως rollback μέχρι την επιτυχή QA validation.