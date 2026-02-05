# ACT-Port Analysis Context

**Date**: February 5, 2026  
**Ticket**: CTA-359  
**Purpose**: Capture context for ACT-Port planning session

---

## What We Have (evenkeel-controltower-app / VCT Anywhere)

### Reusable Components (High Confidence)
| Component | Description |
|-----------|-------------|
| Offline-First Architecture | Client-generated UUIDs, sync queue, conflict resolution |
| DatabaseService abstraction | Platform-agnostic SQLite/Postgres pattern |
| Authentication (Cognito) | JWT tokens, token refresh flow |
| Sync Engine | Upload queue with batching, retry, idempotency |
| UI Component Library | Button, Card, Header, modals, inputs |
| Theme System | Colors, spacing, typography |
| Audit Logging | S3 presigned URL upload pattern |
| Network/Battery Detection | Connectivity monitoring |

### Adaptable Components (Medium Confidence)
| Component | VCT Version | ACT-Port Adaptation Needed |
|-----------|-------------|---------------------------|
| BaplieBay Visualization | Bay-Row-Tier vessel grid | Stack/Block-Row-Tier yard grid |
| Inspection Workflow | Walkaround by deck/bay | Walkaround by yard zone/block |
| Dashboard (HomeScreen) | 4-panel vessel focus | 4-panel terminal focus |
| Reefer State Tables | vessel_id + baplie_id | terminal_id + yard_slot |

---

## What Backend Team Is Building (evenkeel-terminal)

### TOS Integration Architecture
- **Inbound (to TOS)**: SOAP 1.1 API via `update-reefers` endpoint
- **Outbound (from TOS)**: JMS events via Amazon MQ for container moves
- **Tech Stack**: AWS Serverless (Lambda/Rust + TypeScript) + Pulumi + PostgreSQL

### Key TOS Events
| Event | Meaning |
|-------|---------|
| `UNIT_DSCH` | Container discharged from vessel |
| `UNIT_RECEIVE` | Container received at gate |
| `UNIT_YARD_MOVE` | Container moved in yard |
| `UNIT_POWER_CONNECT` | Reefer plugged in |
| `UNIT_POWER_DISCONNECT` | Reefer unplugged |

### TOS API Endpoints (Terminal side)
| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/terminals/{id}/reefers` | List reefers in yard |
| `PUT` | `/terminals/{id}/reefers/{containerId}` | Update reefer readings |
| `POST` | `/terminals/{id}/reefers/bulk` | Bulk update reefers |

---

## Spec Gaps Identified

### 🔴 Critical Gaps (Blocking)
1. **No Yard Visualization Spec** - How to display containers in yard? Blocks? Rows? What's the coordinate system?
2. **No Data Model for Terminal** - What's the equivalent of vessel_id/baplie_id for port context?
3. **TOS Integration Scope Unclear** - What data flows tablet → TOS directly? What goes through ACT-Port backend?
4. **Authentication Model Missing** - Cognito? SSO with terminal systems? Per-user or per-device?
5. **Multi-Tablet Sync** - How do concurrent inspections work? Real-time sync required?

### 🟡 Medium Gaps (Clarification Needed)
1. **Dongle Workflow** - What's the actual process? Bluetooth pairing? Manual entry?
2. **Alarm SLA** - "60 seconds" notification - to whom? How? Push notification?
3. **OCR Phase 2** - Camera integration - any existing library preference?
4. **Geolocation** - GPS precision needed? Indoor positioning?

### 🟢 Assumed (Based on VCT Experience)
1. Offline-first is required (confirmed in spec)
2. Manual temperature entry similar to VCT
3. Alarm code structure reusable from VCT alarm types

---

## Questions for Product

See main planning document for prioritized questions.

---

## External Research: Reefer Compliance & Claims Domain

**Research Date**: February 5, 2026  
**Purpose**: Understand insurance/claims requirements for terminal reefer app

### Sources to Review

| # | Source | URL | Focus Area |
|---|--------|-----|------------|
| 1 | West P&I Loss Prevention Bulletin | https://www.westpandi.com/globalassets/loss-prevention/loss-prevention-bulletins/west-of-england---loss-prevention-bulletin---the-carriage-of-reefer-containers.pdf | Insurance claims, defensible records |
| 2 | Brookes Bell Guide | https://www.brookesbell.com/news-and-knowledge/article/a-complete-guide-to-reefer-containers-159580/ | Industry best practices |
| 3 | Identec Solutions (Monitoring) | https://www.identecsolutions.com/news/reefer-container-monitoring-system-it-driven-processes-for-next-level-customer-experience | Audit trails, customer experience |
| 4 | Port Strategy (Navis N4) | https://www.portstrategy.com/download?ac=107584 | TOS integration patterns |
| 5 | Identec Reefer Runner | https://www.identecsolutions.com/reefer-runner-for-smart-terminals | Competitor analysis, work order types |

---

### 1. Insurance/Claims Requirements

**What makes a claim defensible?**
> *(Extract from West P&I bulletin and Brookes Bell)*
> 
> - [ ] TODO: Review sources and fill in

**Key data points required for claims:**
| Data Point | Required For | Source |
|------------|--------------|--------|
| Temperature readings at intervals | Temperature deviation claims | |
| Setpoint vs actual | Proving correct operation | |
| Power connection/disconnection times | Terminal liability | |
| Alarm acknowledgement timestamps | Response time proof | |
| Inspector identification | Chain of custody | |
| Geolocation/position | Proving container location | |

**Common claim scenarios:**
1. **Cargo spoilage** - Terminal blamed for:
   - [ ] TODO: Extract common causes
2. **Temperature excursion** - Evidence needed:
   - [ ] TODO: Extract requirements
3. **Power interruption** - Proof required:
   - [ ] TODO: Extract requirements

---

### 2. Compliance Proof Requirements

**What constitutes "defensible documentation"?**
> *(Extract key requirements here)*

**Audit trail requirements:**
| Element | Why It Matters | Source |
|---------|----------------|--------|
| Immutable timestamps | Cannot be altered post-incident | |
| User authentication | Proves who performed action | |
| GPS coordinates | Proves location at time of inspection | |
| Photo evidence | Visual proof of conditions | |
| Continuous monitoring | Gap-free record | |

**Regulatory/industry standards mentioned:**
- [ ] TODO: List any standards (ISO, HACCP, ATP, etc.)

---

### 3. Work Order Types in Terminal Operations

**From Identec Reefer Runner and industry sources:**

| Work Order Type | Description | Trigger | Required Data |
|-----------------|-------------|---------|---------------|
| **Connect (Plug-in)** | Power connection | Container arrival | Time, inspector, location |
| **Disconnect (Unplug)** | Power removal | Container departure | Time, inspector, final readings |
| **PTI (Pre-Trip Inspection)** | Pre-shipment check | Booking/export | Full inspection data |
| **Alarm Response** | React to temperature alarm | Alarm trigger | Response time, resolution |
| **Scheduled Inspection** | Routine check | Timer/SLA | Standard readings |
| **Setpoint Change** | Modify temperature | Customer request | Before/after, authorization |
| *(Add more as found)* | | | |

**Work order lifecycle:**
```
Created → Assigned → In Progress → Completed → Closed
                   ↓
             (Alarm escalation if SLA missed)
```

---

### 4. Gap: Monitoring vs Execution Proof

**The problem:**
> Monitoring systems (dongles, OEM telematics) capture *what the reefer is doing*
> but NOT *what the terminal staff did*.

**Evidence of this gap from sources:**
> *(Extract quotes/observations here)*

| System | Captures | Does NOT Capture |
|--------|----------|------------------|
| OEM Telematics | Temp, setpoint, alarms | Who responded, when, what action |
| Dongle Systems | Periodic readings | Inspector actions, work order completion |
| TOS (Navis N4) | Container moves, power events | Inspection details, readings |
| Manual Clipboard | Readings at point-in-time | Continuous data, audit trail |

**ACT-Port fills this gap by:**
- [ ] TODO: Document how our app bridges this

---

### 5. "Evidence Pack" for Disputes

**What should a terminal be able to produce when blamed for cargo damage?**

**From insurance/legal sources:**
| Document/Evidence | Purpose | Our App Captures? |
|-------------------|---------|-------------------|
| Continuous temperature log | Show no excursion occurred | Via OEM/dongle |
| Power connection timestamps | Prove when power applied | Via TOS events |
| Inspection records with timestamps | Prove monitoring happened | ✅ Manual inspections |
| Alarm acknowledgement times | Prove response SLA met | ✅ Alarm workflow |
| Inspector credentials/signature | Chain of custody | ✅ User auth |
| GPS/location proof | Container was where TOS said | ✅ PCT-A-009 |
| Photo evidence | Visual conditions | Phase 2 (OCR camera) |
| Work order completion proof | Terminal action documented | ✅ Sync records |

**Ideal evidence pack contents:**
1. **Timeline**: Arrival → Power → Inspections → Alarms → Departure
2. **Continuous data**: All temperature readings during dwell
3. **Action log**: Every human intervention with timestamps
4. **System log**: All TOS events (moves, power changes)
5. **Export**: Single PDF/ZIP for claims adjuster

---

### 6. Pain Points in Current Manual Processes

**From sources:**

| Pain Point | Impact | Mentioned In |
|------------|--------|--------------|
| Paper clipboards not synced | Data entry delay, errors | Brookes Bell |
| Multiple systems (TOS, dongle, clipboard) | No single source of truth | Identec |
| Dongle installation time/risk | Labor cost, safety | Already in spec |
| No proof of inspection timing | Claims disputes | |
| SLA tracking is manual | Missed alarms | |
| *(Add more as found)* | | |

---

### 7. Competitor Feature Analysis (Identec Reefer Runner)

**Key features to match/exceed:**

| Feature | Reefer Runner | ACT-Port Status |
|---------|---------------|-----------------|
| Real-time monitoring | ✅ | ✅ Via OEM |
| Alarm notifications to TOS | ✅ 60 sec | ✅ PCT-S-005 |
| Yard location visualization | ✅ | Phase 2 |
| Work order management | ✅ | Phase 2 (PCT-S-007) |
| Audit trail export | ? | TODO |
| Integration with multiple TOS | ? | Initially N4 only |

---

### 8. Key Quotes/Insights

> *(Copy important quotes from each source here with attribution)*

**West P&I Bulletin:**
> "*[Quote about defensible records]*"

**Brookes Bell:**
> "*[Quote about inspection requirements]*"

**Identec:**
> "*[Quote about audit trails]*"

---

### 9. Implications for ACT-Port App

**Must-have for claims defense:**
1. [ ] Immutable timestamps (client-generated, server-verified)
2. [ ] GPS on every inspection record (already in spec: PCT-A-009)
3. [ ] User authentication for every action
4. [ ] Alarm response time tracking
5. [ ] Export function for evidence packs

**Nice-to-have (Phase 2+):**
1. [ ] Photo capture with metadata
2. [ ] Digital signature capture
3. [ ] Offline-resilient timestamps (device time + server sync)
4. [ ] PDF report generation

**Questions for Product/Legal:**
1. What level of audit logging is required for your customers?
2. Do we need to be compliant with any specific standards (ATP, HACCP)?
3. What claims has Net Feasa seen where better records would have helped?
4. Should we build an "Evidence Export" feature for claims?

---

*Last Updated: February 5, 2026*
*Status: Template - needs research completion*
