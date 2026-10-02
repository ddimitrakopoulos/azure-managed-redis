# redis-cytaweb-premium-prod

Σημαντικές επιλογές όπως ορίζονται στο `main(2).bicep`.

| Επιλογή | Τιμή |
| --- | --- |
| Τύπος resource | Azure Cache for Redis (`Microsoft.Cache/Redis`, API `2025-08-01-preview`) |
| Region | West Europe |
| Environment / criticality | prod / high |
| Workload | portal |
| Redis version | 6.0 |
| SKU | Premium, family P, capacity 1 |
| TLS | Υποχρεωτικό, ελάχιστη έκδοση 1.2 |
| Non-TLS port | Απενεργοποιημένο |
| Public network access | Απενεργοποιημένο |
| Access-key authentication | Ενεργό |
| Zones | 1, 2, 3 |
| Zone allocation | UserDefined; preferred primary zone 1 |
| Replicas | 3 ανά primary/master |
| Update channel | Stable |
| Private Endpoint connection | Approved |

## Capacity και topology

- `maxclients`: 7,500
- Memory reservations: `maxmemory-reserved`, `maxfragmentationmemory-reserved` και `maxmemory-delta` = 642 MB.
- User-defined zone topology: nodes `0` και `3` στη zone 1, node `1` στη zone 2 και node `2` στη zone 3.
- Δεν ορίζεται `maxmemory-policy`; χρησιμοποιείται η πλατφορμική προεπιλογή.

## Data access policies

Ορίζονται οι built-in access policies **Data Contributor**, **Data Owner** και **Data Reader**. Η πρώτη αφαιρεί dangerous commands, η δεύτερη δίνει πλήρη δικαιώματα και η τρίτη είναι read/connection-oriented με περιορισμένες client commands.

## Προτεινόμενη αντικατάσταση με Azure Managed Redis

| Επιλογή target | Πρόταση |
| --- | --- |
| Όνομα | `redis-cytaweb-premium-prod-amr-we-01` |
| Region και tier | West Europe, Balanced B5 |
| Availability | HA, με zone redundancy όπου διατίθεται στην περιοχή |
| Cluster policy | OSS clustering, εκτός αν RediSearch ή legacy-client constraint απαιτεί Enterprise clustering |
| Network | Private Endpoint, private DNS zone συνδεδεμένη στα production VNets και χωρίς public access |
| Transport | TLS στο port 10000 |
| Authentication | Microsoft Entra ID / managed identity ως στόχος· access key μόνο ως προσωρινό compatibility fallback |
| Modules και persistence | Επιλογή πριν από το create, μετά από τεκμηριωμένο use case |

1. Μετράμε peak `used_memory`, fragmentation, evictions, throughput, connection count και TTLs. Το B5 είναι αρχικό candidate και όχι sizing guarantee.
2. Δημιουργούμε AMR με HA, Private Endpoint και DNS. Επαληθεύουμε resolution και TLS connectivity από κάθε production workload και on-premises route.
3. Εφόσον το source είναι Premium, μπορεί να χρησιμοποιηθεί RDB export/import για point-in-time load. Καλύπτουμε writes μετά το snapshot με write freeze ή idempotent dual write.
4. Πριν το cutover δοκιμάζουμε Redis 7.4, cluster redirects, same-slot multi-key/Lua flows, reconnect/failover και database-0-only behavior.
5. Κάνουμε count/sample/TTL και business-invariant reconciliation, μεταφέρουμε reads σταδιακά και αλλάζουμε το application hostname στο canonical AMR endpoint. Το legacy cache παραμένει διαθέσιμο για το συμφωνημένο rollback window.