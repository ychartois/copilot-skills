# ACT-Port Strategic Reframe: Execution Layer, Not Monitoring Dashboard

**Date**: February 5, 2026  
**Context**: CTA-359 planning session  
**Source**: Deep Seek analysis on clerk-first positioning

---

## The Key Insight

> **Monitoring systems capture what the reefer is doing. ACT-Port captures what the terminal staff did.**

This is the differentiator. Don't compete with Identec/dongle vendors on "we show temperatures". Own the **human workflow proof**.

---

## Strategic Positioning

### ❌ What We're NOT Building
- Another temperature dashboard
- A prettier version of TOS reefer screens
- Telemetry visualization

### ✅ What We ARE Building
- **Work order execution engine** - Turn TOS work orders into verifiable actions
- **Compliance proof generator** - Timestamp, user, location, photo = evidence pack
- **Spoilage prevention tool** - Alarm → Acknowledge → Act → Prove workflow
- **Claims defense asset** - "Here's exactly what we did, when, and by whom"

---

## The 4 Core Workflows (MVP)

Based on the analysis, these are the essential workflows:

### 1. Connect/Disconnect Work Orders
- Receive work order from TOS (UNIT_POWER_CONNECT / UNIT_POWER_DISCONNECT)
- Clerk sees it in prioritized inbox
- Clerk executes, confirms with photo/scan
- Proof flows back to TOS + audit log

### 2. Manual Reading Rounds
- Scheduled inspection of non-telematics reefers
- Scan container, record readings, timestamp auto-captured
- Side-by-side view if IoT data exists (reconciliation)
- Flag discrepancies for escalation

### 3. Alarm Response Playbooks
- Alarm triggers acknowledgement timer
- Clerk gets "do this next" guidance
- Escalation path if not resolved in SLA
- Full timeline captured

### 4. Evidence Pack Export
- Per-container export for disputes
- All actions, readings, photos, timestamps
- Defensible for insurance claims

---

## How This Changes Our Technical Approach

### Data Model Shift

**Old thinking** (monitoring-centric):
```
Terminal → Reefers → Readings → Alarms
```

**New thinking** (execution-centric):
```
Terminal → Work Orders → Tasks → Actions → Proof
                              ↓
                         Reefer State (enrichment)
```

### Key Entities to Add

| Entity | Description |
|--------|-------------|
| `work_order` | From TOS, has type, priority, due_time, container_id |
| `task` | Executable unit (connect, disconnect, read, respond) |
| `action` | What clerk did (timestamp, user, location, photo_url) |
| `evidence_pack` | Aggregated proof per container/incident |

### TOS Integration Becomes Bidirectional

1. **TOS → ACT-Port**: Work orders, container positions, reefer requirements
2. **ACT-Port → TOS**: Work order completion status, inspection data

This is already designed in `evenkeel-terminal` via the SOAP `update-reefers` endpoint!

---

## Implications for Questions

### Questions Now Answered by This Framing

| Original Question | Answer (from execution framing) |
|-------------------|--------------------------------|
| Q2: Tablet → TOS directly? | No. Tablet → ACT-Port API → TOS. We own the audit trail. |
| Q3: Multi-tablet conflict? | Work orders are assigned. Two clerks don't get same task. |
| Q6: Dongle workflow? | "Confirm dongle installed" is a task type with proof capture |
| Q7: 60-second alarm? | Alarm → Task created → Timer starts → Clerk acknowledges |

### Questions Still Open

| Question | Why Still Needed |
|----------|------------------|
| Q1: Yard coordinate system | Still need for container location/routing |
| Q4: Authentication model | Still need to identify "who did it" |
| Q5: Terminal entity model | Still need onboarding flow |
| Q8: Geolocation precision | For proof of "where" action happened |

---

## What We Can Now Propose to Product

### MVP Feature Set (aligned with execution framing)

1. **Work Order Inbox**
   - Pull from TOS via existing JMS events
   - Prioritize by risk (temp deviation, time since last check)
   - Bundle by yard zone

2. **Task Execution Screens**
   - Connect/Disconnect confirmation
   - Manual reading capture (reuse VCT TemperatureNumpad)
   - Alarm acknowledgement with timer

3. **Proof Capture**
   - Auto timestamp + user + GPS
   - Optional photo (reuse camera from PCT-A-005)
   - Signature if required

4. **Evidence Export**
   - Per-container timeline
   - PDF or structured JSON for claims
   - Integration with audit log system (reuse VCT pattern)

### What We Reuse from VCT Anywhere

| Component | Reuse Level |
|-----------|-------------|
| Offline-First Sync | ✅ 100% |
| Authentication | ✅ 100% |
| Audit Logging | ✅ 100% |
| DatabaseService | ✅ 100% |
| UI Components | ✅ 90% |
| TemperatureNumpad | ✅ 100% |
| Inspection Record Schema | 🔄 Adapt to "Action" schema |
| BaplieBay Visualization | 🔄 Adapt to Yard layout |
| Alarm Management | 🔄 Adapt to "Task" workflow |

---

## Competitive Positioning

### vs. Identec Reefer Runner
- They do: Hardware dongles + monitoring dashboard
- We do: **Human workflow execution + compliance proof**
- Coexistence: We can ingest their data as one telemetry source

### vs. Navis N4 Built-in
- They do: Work order generation, yard planning
- We do: **Mobile execution layer** that N4 lacks
- Integration: We complete their workflow loop

---

## Next Steps

1. ✅ Validate this framing with Product (Ruth/Domhnall)
2. Draft work order data model
3. Map TOS JMS events → Work Order types
4. Wireframe the 4 core workflows
5. Estimate MVP timeline

---

## Key Quotes to Use with Product

> "Claims risk is often about set point not being maintained and **not having defensible records**." - West P&I

> "The weakest link is: did the right person do the right thing, at the right time, and **can we prove it**."

> "Most platforms either do telemetry, or do manual logs, but **don't help the clerk resolve conflicts cleanly**."
