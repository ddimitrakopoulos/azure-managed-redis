# Azure Managed Redis - Πλήρης Τεχνική Αναφορά Μετάβασης

**Σκοπός:** πλήρης τεχνική αναφορά για μετάβαση Azure Cache for Redis Basic, Standard και Premium σε Azure Managed Redis (AMR).  
**Περιοχή:** West Europe.  
**Υλοποίηση από εμάς:** target AMR resources, data migration, Private Endpoint/VNet/DNS integration, τεχνικό cutover, validation και rollback.  
**Εκτός scope:** προϋπολογισμός, notifications, καθημερινή λειτουργική διαχείριση και privileges.

## 1. Inventory

| Name | Location | Status | Size | SKU | Subscription | Resource link |
| --- | --- | --- | --- | --- | --- | --- |
| `redis-cytaweb-dev-we-01` | West Europe | Running | 1 GB | Standard | Cyta Dev Environment | [Portal](https://portal.azure.com#resource/subscriptions/61e13f14-79e8-46f5-a690-b438810c9425/resourceGroups/CytaWebSiteDev/providers/Microsoft.Cache/Redis/redis-cytaweb-dev-we-01) |
| `redis-cytaweb-premium-prod` | West Europe | Running | 6 GB | Premium | Cyta Production Environment | [Portal](https://portal.azure.com#resource/subscriptions/75fbc94c-0d25-434d-9fd2-6719b79ebd84/resourceGroups/CytaWebSiteProd/providers/Microsoft.Cache/Redis/redis-cytaweb-premium-prod) |
| `redis-cytaweb-prod-we-01` | West Europe | Running | 6 GB | Premium | Cyta Production Environment | [Portal](https://portal.azure.com#resource/subscriptions/75fbc94c-0d25-434d-9fd2-6719b79ebd84/resourceGroups/CytaWebSiteProd/providers/Microsoft.Cache/Redis/redis-cytaweb-prod-we-01) |
| `redis-cytaweb-qa` | West Europe | Running | 1 GB | Standard | Cyta QA Environment | [Portal](https://portal.azure.com#resource/subscriptions/7bb87719-8b7f-4cf5-9759-6051ba7eb0b5/resourceGroups/CytaWebSiteQA/providers/Microsoft.Cache/Redis/redis-cytaweb-qa) |
| `redis-cytaweb-qa-we-01` | West Europe | Running | 1 GB | Standard | Cyta QA Environment | [Portal](https://portal.azure.com#resource/subscriptions/7bb87719-8b7f-4cf5-9759-6051ba7eb0b5/resourceGroups/CytaWebSiteQA/providers/Microsoft.Cache/Redis/redis-cytaweb-qa-we-01) |
| `redis-cytaweb-test-standard-we-02` | West Europe | Running | 1 GB | Standard | Cyta Test Environment | [Portal](https://portal.azure.com#resource/subscriptions/bc72ff26-44bb-4263-8e1d-426c5c3d1eb3/resourceGroups/CytaWebSiteTest/providers/Microsoft.Cache/Redis/redis-cytaweb-test-standard-we-02) |
| `redis-cytaweb-test-v6` | West Europe | Running | 1 GB | Standard | Cyta Test Environment | [Portal](https://portal.azure.com#resource/subscriptions/bc72ff26-44bb-4263-8e1d-426c5c3d1eb3/resourceGroups/CytaWebSiteTest/providers/Microsoft.Cache/Redis/redis-cytaweb-test-v6) |

## 2. Στρατηγική και waves

Επιλέγουμε **self-service migration**: νέο AMR, ανεξάρτητο network/data validation, ελεγχόμενο application switch και διατήρηση του source ως rollback target. Η σειρά είναι Test → Dev → QA → πρώτο Production → δεύτερο Production.

| Wave | Caches | Initial AMR target | Σκοπός |
| --- | --- | --- | --- |
| 1 | Τα δύο Test | Balanced B1 | Client, DNS, clustering και data-strategy rehearsal |
| 2 | Dev | Balanced B1 | Repeatable provisioning και rollout pattern |
| 3 | Τα δύο QA | Balanced B1, HA | Production-like load, HA και rollback validation |
| 4 | `redis-cytaweb-premium-prod` | Balanced B5, HA | Πρώτο production cutover |
| 5 | `redis-cytaweb-prod-we-01` | Balanced B5, HA | Επανάληψη αποδεδειγμένου runbook |

Τα B1/B5 είναι candidates. Επικυρώνονται με πραγματικά peak metrics και workload replay.

## 3. Γιατί AMR

Το AMR χρησιμοποιεί Redis Enterprise αντί OSS Redis. Το Redis Enterprise εκτελεί πολλαπλά shards ανά node και αξιοποιεί περισσότερα vCPU για command processing. Αυτό επιτρέπει υψηλότερο potential throughput και καλύτερη latency, χωρίς να εγγυάται συγκεκριμένο multiplier. Το αποτέλεσμα επιβεβαιώνεται με P95/P99, throughput, CPU, bandwidth, connection και eviction measurements.

Επιπλέον δυνατότητες: active geo-replication, persistence και import/export σε όλα τα AMR SKU, καθώς και Redis modules. Αυτές επιλέγονται βάσει ανάγκης και δεν είναι από μόνες τους λόγος για αλλαγή application architecture.

## 4. SKU, usable memory και performance tier

Το AMR διαστασιολογείται σε δύο ανεξάρτητους άξονες: συνολική μνήμη και performance tier.

### 4.1 Memory size

Το AMR κρατά περίπου 20% συνολικής μνήμης για system operations, replication/failover buffer και overhead.

$$\text{required AMR total memory} = \frac{\text{peak usable memory}}{0.80}$$

Συλλέγουμε 30 ημέρες `Used Memory`, peak fragmentation, evictions, key count και TTL distribution. Συγκριτικά, το legacy ACR συχνά εκτιμάται με περίπου 10% reservation. Δεν επιλέγουμε target μόνο από 1 GB ή 6 GB nominal size. Για 10 GB usable demand χρειαζόμαστε τουλάχιστον 12.5 GB total AMR memory.

### 4.2 Performance tier

| Tier | Χρήση |
| --- | --- |
| Balanced | Αρχική επιλογή για άγνωστο ή ισορροπημένο workload. |
| Memory Optimized | Memory pressure φτάνει πριν CPU/network bottleneck. |
| Compute Optimized | Throughput-intensive ή latency-sensitive workload με CPU/bandwidth pressure. |
| Flash Optimized | Πολύ μεγάλα read-heavy datasets με hot/cold access pattern. Δεν είναι κατάλληλο default για αυτά τα 1/6 GB caches. |

### 4.3 Scaling

Το AMR επιτρέπει αλλαγή memory size και performance tier. Με HA αναμένονται σύντομα reconnect blips κατά scaling/failover, επομένως οι clients χρειάζονται pooling και retry with jitter. Το scale-down απαιτεί memory usage χαμηλότερη από το νέο usable capacity και επηρεάζεται από shard/vCPU compatibility. Δεν αλλάζει clustering policy με scaling και δεν γίνεται μετάβαση μεταξύ in-memory και Flash Optimized tiers. Χρησιμοποιούμε DNS hostname, ποτέ στατική IP.

## 5. HA, zone redundancy και geo-replication

### High availability

Με HA, primary και replica shards αναπτύσσονται σε τουλάχιστον δύο nodes. HA είναι υποχρεωτική επιλογή για QA/Production. Non-HA είναι κατάλληλο μόνο για rehydratable Dev/Test, δεν έχει SLA και μπορεί να χάσει data σε maintenance.

### Zone redundancy

Σε region με Availability Zones, HA AMR είναι zone-redundant by default. Προσφέρει ανθεκτικότητα σε zone failure, αλλά δεν αντικαθιστά client retries ούτε regional DR.

### Geo-replication

Το AMR παρέχει active geo-replication, με reads/writes σε linked caches διαφορετικών περιοχών. Το legacy Premium προσφέρει passive geo-replication με read-only secondary. Δεν υπάρχει explicit AMR `Failover` command: η εφαρμογή μεταβαίνει σε άλλο endpoint σε regional outage. Εφόσον όλα τα current caches είναι West Europe, το geo-replication είναι ανεξάρτητη DR πρωτοβουλία.

## 6. Redis OSS, Redis Enterprise και clustering

| Θέμα | Legacy OSS Redis | AMR Redis Enterprise |
| --- | --- | --- |
| Command execution | Single-threaded ανά Redis server process | Πολλά parallel shards ανά node |
| vCPU use | Περιορισμένο command parallelism | Καλύτερη αξιοποίηση πολλών vCPU |
| Node behavior | Primary/replica node roles | Primaries και replicas κατανέμονται σε nodes |
| Connection handling | OSS endpoint model | Proxy, connection management και self-healing stack |

Το AMR είναι clustered by default. Η policy επιλέγεται πριν το create και δεν αλλάζει χωρίς recreation.

| Policy | Επιλογή | Κρίσιμη επίπτωση |
| --- | --- | --- |
| OSS clustering | Default για cluster-aware clients | Υψηλή throughput/χαμηλή latency. Client ακολουθεί `MOVED`; RediSearch δεν υποστηρίζεται. |
| Enterprise clustering | RediSearch ή legacy client compatibility | Single proxy endpoint, αλλά πιθανό compute/network bottleneck. |
| Nonclustered | Μόνο όταν η εφαρμογή δεν ανέχεται cluster topology | Έως 25 GB και χαμηλότερη performance. |

Για OSS policy, multi-key commands, Lua και `MULTI/EXEC` πρέπει να έχουν keys στο ίδιο hash slot. Χρησιμοποιούμε hash tags όπως `{customer:42}:profile` και `{customer:42}:orders`. Στο Enterprise policy cross-slot επιτρέπονται μόνο `DEL`, `MSET`, `MGET`, `EXISTS`, `UNLINK` και `TOUCH`.

## 7. Network integration

Το AMR δεν υποστηρίζει VNet injection ή IP-based firewall rules. Για private workloads εφαρμόζουμε Azure Private Link.

```mermaid
flowchart LR
    A[Workload: App Service / AKS / VM] --> B[Private DNS zone]
    B --> C[Private Endpoint]
    C --> D[Azure Managed Redis]
    E[On-premises DNS forwarder] --> B
```

### Εκτέλεση

1. Δημιουργούμε Private Endpoint για κάθε private target AMR.
2. Συνδέουμε private DNS zone στα workload VNet.
3. Ρυθμίζουμε/ελέγχουμε DNS forwarding για on-premises routes όπου απαιτείται.
4. Ελέγχουμε resolution, TCP/TLS connectivity, NSG και routing από όλα τα runtime paths.
5. Καταγράφουμε legacy/target endpoints για switch και rollback.

Το target hostname είναι `<name>.<region>.redis.azure.net`, αντί για `<name>.redis.cache.windows.net`.

## 8. TLS και authentication

TLS κρυπτογραφεί commands, values και credentials στη μεταφορά και επαληθεύει τον server μέσω certificate.

| Ρύθμιση | Legacy cache | AMR |
| --- | --- | --- |
| TLS port | 6380 | 10000 |
| Non-TLS port | 6379 | 10000 |
| Ταυτόχρονο TLS/non-TLS | Ναι | Όχι |
| TLS versions | 1.2, 1.3 | 1.2, 1.3 |

Επιλέγουμε TLS. Στο AMR όλοι οι clients ενός cache χρησιμοποιούν το ίδιο mode, ορισμένο στο provisioning. Το AMR υποστηρίζει Microsoft Entra ID authentication και access keys. Στόχος είναι Entra ID + managed identities όπου υποστηρίζεται· access keys χρησιμοποιούνται μόνο ως μεταβατική compatibility επιλογή. Δεν αποθηκεύουμε keys/tokens σε markdown ή Git.

## 9. Application compatibility

Οι περισσότερες εφαρμογές χρειάζονται αλλαγή configuration, όχι business-code rewrite. Το minimum connection update είναι νέο hostname, port 10000, νέο key/Entra token και νέο DNS route.

| Compatibility area | Έλεγχος |
| --- | --- |
| Client library | TLS, automatic reconnect, Redis Cluster API, `MOVED` redirects |
| Redis version | AMR 7.4 αντί legacy 6.x· tests για commands/scripts |
| Multi-key logic | Hash tags ή redesign για same-slot keys |
| Logical databases | AMR έχει database 0 μόνο· αντικατάσταση `SELECT <db>` με prefixes |
| Keyspace notifications | Δεν υποστηρίζονται· αντικατάσταση event consumers με app event, queue ή scheduler |
| Manual reboot | Δεν υποστηρίζεται· Flush μόνο για clearing target data |
| Scheduled updates | Preview· όχι dependency του rollout |

Το AMR προσφέρει RedisJSON, RedisBloom, RedisTimeSeries και RediSearch. Modules επιλέγονται στην αρχική δημιουργία και δεν ενεργοποιούνται αργότερα. Δεν τα επιλέγουμε χωρίς business/technical use case.

## 10. Persistence και data classification

Το AMR υποστηρίζει persistence σε όλα τα SKU. Το legacy Standard δεν το υποστηρίζει και το Premium το υποστηρίζει. Persistence είναι recovery aid, όχι source of truth ή migration mechanism.

Για κάθε cache ταξινομούμε τα data ως:

- **Rehydratable cache:** μπορεί να ξαναγεμίσει από authoritative datastore.
- **Session/queue/lock:** απαιτεί έλεγχο data loss, idempotency και reconciliation.
- **Business state:** απαιτεί σαφές authoritative source και recovery plan.

Ελέγχουμε persistence setting στο legacy Premium και αποφασίζουμε target persistence πριν από τη data migration.

## 11. Data migration options

| Μέθοδος | Πότε επιλέγεται | Πλεονέκτημα | Περιορισμός |
| --- | --- | --- | --- |
| Cold start/cache warming | Cache-aside και rehydratable data | Απλή, χαμηλού data-copy risk | Προκαλεί cache-miss load στο origin |
| RDB export/import | Premium source, acceptable point-in-time snapshot | Επίσημη, απλή snapshot διαδρομή | Δεν περιλαμβάνει writes μετά το export |
| Dual write | Μηδενική απώλεια state | Ελάχιστο downtime, parallel validation | Θέλει application change, idempotency και δύο systems |
| Programmatic copy | Ειδικό/μεγάλο dataset | Πλήρης έλεγχος | Tooling/development/reconciliation effort |

### 11.1 RDB export/import

1. Εξάγουμε RDB από το legacy **Premium** source.
2. Εισάγουμε στο άδειο AMR target.
3. Ελέγχουμε key count, sampled values, TTL και business invariants.
4. Καλύπτουμε post-snapshot writes με write freeze ή dual write.
5. Αλλάζουμε application configuration και επαληθεύουμε flows.

### 11.2 Dual write

1. Προετοιμάζουμε target AMR, network και authentication.
2. Γράφουμε idempotently σε source και target.
3. Κρατάμε reads στο source έως ότου το target είναι populated.
4. Κάνουμε count/sample/TTL reconciliation.
5. Μεταφέρουμε reads σταδιακά και μετά το target γίνεται primary.

Ορίζουμε conflict policy και authoritative system ανά φάση. Για queues χρησιμοποιούμε idempotent consumers και operation IDs.

### 11.3 Programmatic migration

1. Χρησιμοποιούμε VM στην ίδια περιοχή με το source, με κατάλληλο compute/network.
2. Επιβεβαιώνουμε ότι το target είναι κενό. Flush επιτρέπεται μόνο στο target, ποτέ στο source.
3. Αντιγράφουμε data με cluster-aware, TLS-capable εργαλείο, π.χ. RIOT-X.
4. Κάνουμε reconciliation σε count, samples, TTL και business invariants.
5. Κάνουμε final delta ή write freeze πριν από endpoint switch.

## 12. Built-in migration tooling (preview)

Το tooling μεταφέρει hostname/endpoint προς ήδη δημιουργημένο AMR και προκαλεί σύντομο connection blip, αλλά **δεν μεταφέρει data**.

### Διαδικασία

1. Δημιουργούμε/προρυθμίζουμε AMR και ολοκληρώνουμε data strategy.
2. Στο legacy cache επιλέγουμε **Migrate** και μετά target AMR.
3. Τρέχουμε **Validate** και εξετάζουμε errors/warnings.
4. Επιλέγουμε **Migrate** μόνο όταν τα findings είναι αποδεκτά.
5. Κατά `Migrating` δεν γίνονται άλλες management operations.
6. Μετά την επιτυχία επικυρώνουμε applications και ενημερώνουμε τις εφαρμογές στο canonical AMR hostname.

### Περιορισμοί

- Preview και περιορισμένος rollback χρόνος μετά την επιτυχία.
- Δεν υποστηρίζει Private Endpoint, VNet injection ή geo-replication.
- Δεν αντιγράφει data, managed identities, firewall rules, persistence, update schedules ή keyspace settings.
- Επηρεάζει όλους τους clients του cache ταυτόχρονα και δεν δίνει ακριβή control του cutover timing.

Επομένως δεν το χρησιμοποιούμε ως βασική μέθοδο στα συγκεκριμένα instances, όπου η Private Endpoint integration είναι μέρος του scope.

## 13. Πηγές και επαλήθευση

- [Understand AMR differences and choose a SKU](https://learn.microsoft.com/en-us/azure/redis/migrate/migrate-basic-standard-premium-understand)
- [Migration options](https://learn.microsoft.com/en-us/azure/redis/migrate/migrate-basic-standard-premium-options)
- [Self-service migration plan](https://learn.microsoft.com/en-us/azure/redis/migrate/migrate-basic-standard-premium-self-service)
- [Migration tooling preview](https://learn.microsoft.com/en-us/azure/redis/migrate/migrate-basic-standard-premium-with-tooling)
- [Azure Managed Redis architecture and cluster policies](https://learn.microsoft.com/en-us/azure/redis/architecture)

Επαληθεύουμε availability, capacity, SKU και preview status στο West Europe την ημέρα του provisioning.
