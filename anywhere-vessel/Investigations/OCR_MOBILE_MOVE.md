# VCT Anywhere - Mobile OCR Pivot: Impact Analysis & Battle Plan

**Date**: November 25, 2025  
**Status**: Draft for Internal Review  
**Context**: CEO feedback on tablet UX vs. smartphone + OCR approach

---

## Executive Summary

Ian's observation is valid: **pen & paper beats tablet for mobility**. The proposed smartphone + OCR solution addresses the core UX problem but introduces significant technical and timeline risks with **3 weeks remaining**.

**Recommendation**: Schedule immediate team discussion to evaluate **hybrid approach** vs. **full pivot**.

---

## Impact Analysis

### 1. Timeline Impact ⏱️

**Current Progress:**
- ✅ Tablet UI/UX wireframes completed
- ✅ Backend infrastructure deployed (API Gateway, Cognito, RDS, SQS)
- ✅ Offline sync architecture implemented
- ✅ React Native Windows setup complete
- 🟡 React Native Web/Electron added (Nov 21)
- 🟡 SQLite integration in progress (current branch)

**Additional Work Required for OCR Pivot:**

| Task | Estimated Effort | Risk Level |
|------|-----------------|------------|
| Mobile platform setup (iOS/Android) | 3-5 days | Medium |
| OCR integration (React Native Vision Camera + ML Kit/Tesseract) | 5-7 days | **High** |
| OCR accuracy testing & training for reefer displays | 3-5 days | **High** |
| Mobile UI redesign (phone-sized screens) | 4-6 days | Medium |
| Camera permissions & hardware access | 2-3 days | Medium |
| Image storage & upload optimization | 3-4 days | Medium-High |
| Push notification infrastructure | 2-3 days | Low-Medium |
| Testing on physical devices (various lighting, angles) | 5+ days | **High** |

**Total Additional Effort**: 27-38 days (~5-8 weeks)

**Verdict**: ⚠️ **Full pivot requires 5-8 additional weeks**. Not feasible in 3-week timeline without significant scope reduction.

---

### 2. Platform Changes 📱

**Current State:**
- Windows tablet (React Native Windows)
- Electron/Web fallback

**New Requirements:**
- ✅ Android (primary - most crew phones)
- ✅ iOS (secondary - some crew iPhones)
- ❓ Windows tablet (keep as fallback? Or drop?)

**Technical Implications:**
- React Native already supports iOS/Android (less work than starting from scratch)
- Need macOS for iOS builds (do we have access?)
- Android build pipeline already possible on Linux
- App store deployment process (TestFlight for iOS, Google Play internal testing)

**Cost Impact:**
- Apple Developer Program: $99/year
- Google Play Developer: $25 one-time
- Physical test devices needed (various Android models, iPhone)

---

### 3. Backend & Sync Changes 🔄

**What Doesn't Change:**
- ✅ Authentication (Cognito)
- ✅ Offline-first architecture
- ✅ Delta sync logic
- ✅ RDS schema
- ✅ SQS async processing

**New Requirements:**

#### Photo/Image Upload
**Challenge**: OCR images = 1-5 MB per photo × 100-500 reefers = **100-2500 MB per walkaround**

**Solution Options:**
1. **S3 Direct Upload** (recommended)
   - Pre-signed URLs from API
   - Client uploads directly to S3
   - Minimal backend change (add S3 bucket + presigned URL endpoint)
   - Bandwidth: handled by S3, not our API
   
2. **API Gateway Upload**
   - 10 MB payload limit (not suitable for batch)
   - Slower, more expensive

**Architecture Addition:**
```
Phone Camera → Local OCR → Extract data + Save image
    ↓
SQLite (queue images for upload)
    ↓
WiFi Available → Batch upload to S3 (presigned URLs)
    ↓
S3 trigger → Lambda → Process/archive images
```

**Bandwidth Constraints:**
- Poor WiFi: Queue images locally, upload when signal improves
- 4G fallback: Compress images (reduce resolution after OCR)
- Option: Upload data immediately, images later (when on good WiFi)

**Estimated Backend Work**: 3-4 days (S3 bucket, presigned URLs, Lambda trigger)

---

### 4. OCR Technical Constraints 📷

#### Accuracy Challenges
**Reefer Display Characteristics:**
- 7-segment LED displays (easier for OCR)
- LCD screens (harder, glare issues)
- Varying fonts (container IDs are standardized, but manufacturers differ)
- Environmental: sun glare, rain, dirt, scratches on displays
- Angles: crew may not hold phone perfectly perpendicular

**OCR Library Options:**

| Library | Pros | Cons | Accuracy (Est.) |
|---------|------|------|-----------------|
| **Google ML Kit (Text Recognition v2)** | Free, on-device, fast, good for structured text | Requires Google Play Services (Android) | 85-95% |
| **Apple Vision Framework** | Native iOS, excellent accuracy | iOS only | 90-95% |
| **Tesseract OCR** | Open source, cross-platform | Slower, needs training for 7-segment displays | 70-85% (without training) |
| **Custom ML model** | Tailored to reefer displays | Requires training data, time, expertise | Potentially 95%+ |

**Recommended Approach:**
1. Start with **ML Kit (Android)** + **Vision (iOS)** - fastest to market
2. Fallback: Manual entry if OCR confidence < 80%
3. User review screen: "Does this look right?" before saving

**OCR Constraints:**
- **Lighting**: Needs good lighting (daytime walkarounds preferred, flashlight for night)
- **Distance**: Phone must be 15-30cm from display (too close = blur, too far = unreadable)
- **Stability**: Shaky hands = blurry photos (need burst mode or video frame extraction)
- **Processing time**: 0.5-2 seconds per reefer (acceptable)

---

### 5. Device Storage Constraints 💾

**Data Breakdown per Walkaround:**

| Data Type | Size per Reefer | 500 Reefers | Notes |
|-----------|-----------------|-------------|-------|
| Reefer data (JSON) | 1-2 KB | 500 KB - 1 MB | Minimal |
| OCR images (compressed) | 200-500 KB | 100-250 MB | Significant |
| OCR images (original) | 2-5 MB | 1-2.5 GB | **Very significant** |
| SQLite database | - | 10-50 MB | Grows over time |

**Storage Strategy:**
1. **Delete images after successful upload** (retain data only)
2. **Compress images** post-OCR (JPEG quality 70-80%)
3. **Configurable retention**: Keep last N days of images locally
4. **Minimum device requirement**: 2-5 GB free storage (check on app start)

**Typical Crew Phone Storage:**
- Budget Android: 32-64 GB (often 50%+ used)
- iPhone: 64-128 GB (better, but photos/apps take space)

**Risk**: Crew phones may run out of storage mid-walkaround. **Mitigation**: Upload + delete images in batches during walkaround (when WiFi available).

---

### 6. UI/UX Redesign 📐

**Screen Size Shift:**
- Tablet: 10-12" (1920×1200 or similar) → Phone: 5-6.5" (1080×2400 or similar)
- **60-70% smaller screen real estate**

**Design Implications:**

| Feature | Tablet Design | Phone Design | Complexity |
|---------|---------------|--------------|------------|
| Reefer list | Multi-column table | Single-column list, swipe actions | Medium |
| Data entry | Form with multiple fields visible | One field at a time, step-by-step wizard | Medium-High |
| Navigation | Sidebar menu | Bottom tab bar or hamburger menu | Low |
| Camera integration | - | **Full-screen camera viewfinder** | High |
| Review/edit | Side-by-side comparison | Before/after swipe or modal | Medium |
| Alarms | Card list with filters | Condensed list, swipe to dismiss | Medium |

**Camera-First Flow:**
```
1. Tap "Start Walkaround" → Camera opens
2. Point at reefer display
3. OCR detects: Container ID, Supply Temp, Return Temp
4. Quick review screen: "Confirm or Edit"
5. Tap ✓ → Saves to local DB
6. Camera reopens for next reefer
7. Repeat until walkaround complete
8. Sync data + images when on WiFi
```

**Wireframe Rework Needed:**
- All existing wireframes (alarm, inspection, main workflows) need mobile versions
- Estimate: **4-6 days** (if we simplify scope)

---

### 7. Push Notifications for Alarms 🔔

**Current Design**: Alarms shown in app (pull model)  
**Mobile Requirement**: Push notifications (push model)

**Implementation:**

| Component | Technology | Effort |
|-----------|-----------|--------|
| Push notification service | **Firebase Cloud Messaging (FCM)** for Android, **APNs** for iOS | 2-3 days |
| Backend integration | Lambda function to send push when alarm created | 1-2 days |
| Client handling | React Native Push Notification library | 1-2 days |
| Permissions | Request notification permissions on app start | 0.5 days |

**User Experience:**
- Crew receives push: "⚠️ Alarm: Container ABCD1234567 - Supply temp too high"
- Tap notification → Opens app to alarm detail
- Background sync: App fetches latest alarms when push received

**Total Effort**: 2-3 days (relatively straightforward)

---

### 8. Other Risks & Considerations ⚠️

#### 8.1. OCR Failure Fallback
**Problem**: What if OCR can't read a reefer display?  
**Solution**: 
- Manual entry mode (quick keyboard input)
- "Skip for now" option (mark for manual review later)
- Highlight low-confidence readings for user review

#### 8.2. Network Connectivity
**Problem**: Crew may be out of WiFi/4G range during walkaround  
**Current Solution**: Offline-first architecture already handles this ✅  
**New Risk**: Large image uploads may fail → Need robust retry logic with exponential backoff

#### 8.3. Battery Life
**Problem**: Camera + OCR + GPS = high battery drain  
**Mitigation**:
- Optimize camera usage (close between scans)
- Reduce OCR processing (on-device ML, not cloud)
- Warning if battery < 20%
- Crew should start with full charge

#### 8.4. Learning Curve
**Problem**: Crew needs to learn new workflow  
**Mitigation**:
- Onboarding tutorial (first-time app launch)
- "How to use" video (30 seconds)
- In-app help hints
- Train-the-trainer session with one crew member per vessel

#### 8.5. Data Quality
**Problem**: OCR errors = bad data in VCT  
**Mitigation**:
- Confidence threshold (reject readings < 80%)
- User review screen before saving
- Audit trail: Store original images for later verification
- Analytics: Track OCR accuracy over time, improve model

#### 8.6. Container ID Validation
**Problem**: OCR might misread container ID (e.g., "O" vs "0")  
**Solution**:
- Validate against ISO 6346 check digit algorithm
- Cross-reference with BAPLIE data (known containers on vessel)
- Flag suspicious readings for manual review

#### 8.7. Regulatory/Privacy
**Problem**: Photos of reefers might capture people/proprietary info  
**Mitigation**:
- Privacy policy update (photos stored temporarily, deleted after upload)
- GDPR compliance (if operating in EU waters)
- Crew consent for app usage

#### 8.8. Device Compatibility
**Problem**: Older crew phones may not support app  
**Minimum Requirements**:
- Android 8.0+ (2017) or iOS 13+ (2019)
- 2 GB RAM minimum
- Camera with autofocus
- 2-5 GB free storage

**Risk**: Some crew may need company-provided phones (cost implication)

---

## Hybrid Approach: Pragmatic Alternative 🎯

**Proposal**: Start with tablet, add OCR as optional enhancement in Phase 2

### Phase 1 (Current 3-week timeline):
- ✅ Keep tablet as primary device (complete current scope)
- ✅ Manual data entry (proven, low risk)
- ✅ Offline sync (already implemented)
- ✅ Basic alarms & inspection workflows

### Phase 2 (Post-launch, 4-6 weeks):
- 📱 Add mobile (iOS/Android) support
- 📷 Add OCR as **optional** data entry method
- 🔔 Add push notifications for alarms
- 📊 Collect usage data: Do crews prefer OCR or manual entry?

**Benefits:**
- ✅ Delivers working solution in 3 weeks
- ✅ Reduces risk (proven manual entry)
- ✅ Allows OCR validation in production (not rushed)
- ✅ Crew can choose: tablet (bridge) or phone (walkaround)

**Trade-off**: Doesn't immediately solve clipboard problem, but provides working solution faster

---

## Recommendations 🎯

### Option A: Full Pivot to Mobile OCR (High Risk, High Reward)
- **Timeline**: 8-10 weeks total (5-8 weeks more)
- **Risk**: High (OCR accuracy, timeline slip)
- **Reward**: Best UX, crew adoption likely higher
- **Recommendation**: ⚠️ Not feasible in 3 weeks without cutting features

### Option B: Hybrid Approach (Balanced)
- **Timeline**: 3 weeks (Phase 1) + 4-6 weeks (Phase 2)
- **Risk**: Medium (proven tech first, OCR added later)
- **Reward**: Delivers value quickly, iterates based on feedback
- **Recommendation**: ✅ **Recommended** - pragmatic, lower risk

### Option C: Negotiate Timeline Extension
- **Timeline**: Request 6-8 weeks total
- **Risk**: Medium-High (depends on stakeholder flexibility)
- **Reward**: Delivers ideal solution in one go
- **Recommendation**: Consider if business case supports delay

---

## Next Steps 📋

### Immediate (This Week):
1. **Team Discussion** (60-90 min)
   - Review this document
   - Validate effort estimates
   - Team vote: Full pivot vs. Hybrid vs. Extend timeline
   - Identify team members for OCR R&D spike (1-2 days)

2. **Technical Spike** (2-3 days)
   - Proof of concept: React Native + ML Kit OCR
   - Test accuracy on real reefer display photos (need samples!)
   - Validate image upload to S3
   - Report findings to team

3. **Stakeholder Alignment** (Before meeting Ian)
   - Prepare recommendation (with data from spike)
   - Cost/benefit analysis
   - Risk mitigation plan
   - Revised timeline (if needed)

### Prepare for Ian Discussion:
- **Acknowledge**: His observation is correct - clipboard beats tablet for mobility
- **Present Options**: Full pivot vs. Hybrid (with pros/cons/timelines)
- **Recommendation**: Hybrid approach (Phase 1: tablet, Phase 2: mobile OCR)
- **Ask**: 
  - Can timeline extend to 8-10 weeks for full mobile OCR solution?
  - Or deliver tablet in 3 weeks, add mobile OCR in Phase 2?
  - What's more important: speed to market or perfect UX?

---

## Questions for Team Discussion 🤔

1. Do we have macOS machine for iOS builds?
2. Who has React Native mobile experience? (Android/iOS)
3. Who can lead OCR integration research?
4. Can we get sample photos of reefer displays (various manufacturers) for testing?
5. What's our risk appetite? Ship fast vs. Ship perfect?
6. Can we negotiate timeline extension with stakeholders?
7. Should we prototype OCR with one team member's phone this week?

---

## Appendix: Technical Deep Dive

### React Native OCR Libraries

```typescript
// Example: ML Kit Text Recognition (Android/iOS)
import TextRecognition from '@react-native-ml-kit/text-recognition';

async function scanReeferDisplay(imageUri: string) {
  const result = await TextRecognition.recognize(imageUri);
  
  // Parse detected text blocks
  const containerID = extractContainerID(result.text);
  const supplyTemp = extractTemperature(result.text, 'supply');
  const returnTemp = extractTemperature(result.text, 'return');
  
  return {
    containerID,
    supplyTemp,
    returnTemp,
    confidence: result.blocks[0]?.confidence || 0,
    rawText: result.text,
  };
}
```

### Image Upload Flow

```typescript
// 1. Request presigned URL from backend
const { uploadUrl, imageKey } = await api.requestImageUpload({
  containerID: 'ABCD1234567',
  timestamp: new Date().toISOString(),
});

// 2. Upload image directly to S3
await fetch(uploadUrl, {
  method: 'PUT',
  headers: { 'Content-Type': 'image/jpeg' },
  body: compressedImageBlob,
});

// 3. Save metadata to local DB (for sync)
await db.saveReeferReading({
  containerID,
  supplyTemp,
  returnTemp,
  imageKey, // S3 key for later reference
  synced: false,
});
```

### Push Notification Setup

```typescript
// Firebase Cloud Messaging (React Native)
import messaging from '@react-native-firebase/messaging';

// Request permission
await messaging().requestPermission();

// Get FCM token
const fcmToken = await messaging().getToken();

// Send token to backend (save in user profile)
await api.updateUserProfile({ pushToken: fcmToken });

// Handle incoming notifications
messaging().onMessage(async (remoteMessage) => {
  // Show local notification or update UI
  showAlarmNotification(remoteMessage.data);
});
```

---

**Document Status**: Draft for team review  
**Next Review**: Team meeting (before Ian discussion)  
**Owner**: Yannig (to facilitate discussion)
