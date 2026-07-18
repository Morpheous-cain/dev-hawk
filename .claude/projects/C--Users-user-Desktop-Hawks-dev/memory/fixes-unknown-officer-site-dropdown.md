---
name: fixes-unknown-officer-site-dropdown
description: Fixed "Unknown Officer" display and empty site dropdown in clock-in/out module
metadata:
  type: project
---

**Fixed two issues in the dashboard/clock-in module:**

### 1. "Unknown Officer" Issue
**Root cause:** Staff table missing `user_id` column to link to `auth.users`. The `useOfficerAssignments` hook queried by `user_id` which didn't exist.

**Fixes:**
- Migration `20260718000000_add_user_id_to_staff.sql`: Added `user_id UUID REFERENCES auth.users(id)` column with index and RLS policies
- `src/hooks/useOfficerAssignments.ts`: Improved error handling, kept email fallback for existing records

### 2. Empty Site Dropdown in Clock In/Out
**Root cause:** `fetchSites()` in `OfficerClockScreen.tsx` queried non-existent columns (`gps_lat`, `gps_lng`, `geofence_radius_meters`) on `clients` table. GPS data is in `sites.gps_coordinates` text field.

**Fixes:**
- Migration `20260718000001_add_gps_to_sites.sql`: Added GPS/geofence columns to `sites` table
- `src/components/patrol/OfficerClockScreen.tsx`: Rewrote `fetchSites()` to parse `gps_coordinates` string (format: "lat,lng" or "POINT(lat lng)") with hardcoded fallback

### Files Modified
1. `supabase/migrations/20260718000000_add_user_id_to_staff.sql` (new)
2. `supabase/migrations/20260718000001_add_gps_to_sites.sql` (new)
3. `src/hooks/useOfficerAssignments.ts`
4. `src/components/patrol/OfficerClockScreen.tsx`
5. `src/components/control-room/AlarmSOSDesk.tsx` (fixed SOS officer name join from profiles→staff)

**Next:** Apply migrations via Lovable Cloud → Database → SQL Editor