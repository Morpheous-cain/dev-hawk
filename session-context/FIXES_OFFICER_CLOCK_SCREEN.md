# Officer Clock Screen Fixes — 2026-07-20

## Problem
Guard name not displaying and site dropdown empty in `OfficerClockScreen` when a guard's auth account isn't linked to a `staff` record.

## Root Cause
The `useOfficerAssignments` hook looks up staff by:
1. `staff.user_id = auth.uid()` — direct link
2. `staff.email = profiles.email` — fallback via profile

If neither matches (new guard not provisioned, or email mismatch), `staffRecord` is `null`. This cascaded:
- `officerName` undefined → empty name display
- `fetchSites()` gated by `if (officerId)` → never ran → empty dropdown
- `assignedSites` empty → no default selection

## Files Changed
- `src/components/patrol/OfficerClockScreen.tsx`

## Fixes

### 1. Guard Name & Metadata Fallbacks (lines 60-62)
```typescript
const officerName = staffRecord?.full_name || user?.email?.split('@')[0] || 'Unknown Officer';
const officerPosition = staffRecord?.position || 'Guard';
const officerStaffId = staffRecord?.staff_id || '—';
```

### 2. Always Fetch Sites (lines 113-121)
```typescript
useEffect(() => {
  if (assignmentsLoading) return;
  fetchSites();  // Runs regardless of officerId
  if (officerId) {
    checkGPSLocation();
    fetchClockHistory();
    checkCurrentShiftStatus();
  }
}, [assignmentsLoading, officerId]);
```

### 3. Site Selection Fallback (lines 124-131)
```typescript
useEffect(() => {
  if (assignedSites.length > 0 && !selectedSite) {
    setSelectedSite(assignedSites[0].id);
  } else if (sites.length > 0 && !selectedSite) {
    setSelectedSite(sites[0].id);  // Fallback to all sites
  }
}, [assignedSites, sites, selectedSite]);
```

### 4. Helpful Error Messages (lines 388-395)
```typescript
if (!officerId) {
  toast.error("Officer not identified. Please contact admin to link your account to a staff record.");
  return;
}
```

### 5. Consistent Render Values (lines 709-712)
```tsx
<p className="font-medium">{officerName}</p>
<p className="text-xs text-muted-foreground">{officerPosition}</p>
<Badge variant="outline" className="text-xs">{officerStaffId}</Badge>
```

## Verification
- ✅ Build passes (`npm run build`)
- ✅ No TypeScript errors
- ✅ Guard name shows email username when staff record missing
- ✅ Site dropdown populates from `sites` table
- ✅ Default site auto-selects from fallback list

---

## Next: Security Review

This will be a separate systematic pass covering:
1. Authentication & Authorization
2. Database / RLS Policies
3. API / Edge Functions
4. Client-Side Data Exposure
5. Input Validation & Injection
6. Secrets Management
7. Real-time / WebSocket Security
8. File Upload / Storage
9. Logging & Audit Trail
10. Dependencies & Supply Chain