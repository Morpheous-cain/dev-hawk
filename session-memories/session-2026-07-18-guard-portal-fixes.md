---
name: guard-portal-fixes
description: Fixed "Unknown Officer" and empty site dropdown in clock-in/out module
metadata:
  type: project
---

**Fixed two critical issues in the Officer Clock Screen module:**

### 1. "Unknown Officer" Display Issue
**Root cause:** Staff table missing `user_id` column to link to `auth.users`, and no `email` column for fallback matching. The `useOfficerAssignments` hook queried by `user_id` which didn't exist.

**Fixes applied:**
- Migration `20260718000000_add_user_id_to_staff.sql`: Added `user_id UUID REFERENCES auth.users(id)` with index and RLS policies
- Migration `20260718000002_add_email_to_staff.sql`: Added `email` column for email-based fallback matching
- Updated `useOfficerAssignments.ts`: Improved error handling, kept email fallback for existing records without `user_id`
- Updated `types.ts`: Added `user_id` and `email` to staff table types

### 2. Empty Site Dropdown in Clock In/Out
**Root cause:** `fetchSites()` in `OfficerClockScreen.tsx` queried non-existent columns (`gps_lat`, `gps_lng`, `geofence_radius_meters`) on `clients` table. GPS data is in `sites.gps_coordinates` text field.

**Fixes applied:**
- Migration `20260718000001_add_gps_to_sites.sql`: Added `gps_lat`, `gps_lng`, `geofence_radius_meters` columns to `sites` table with index
- Updated `OfficerClockScreen.tsx`: Rewrote `fetchSites()` to parse `gps_coordinates` string (format: "lat,lng" or "POINT(lat lng)") with hardcoded fallback
- Updated `SiteSelector.tsx`: Added GPS fields to interface and query
- Updated `types.ts`: Added new GPS columns to sites table types

### 3. Assigned Sites Not Loading Properly
**Root cause:** `assignedSites` query in `useOfficerAssignments.ts` returned raw `current_site` text instead of site objects with IDs.

**Fix:** Updated query to join with `sites` table and return `{ id, site_name, client_id }` objects.

---

**Files Modified:**
1. `supabase/migrations/20260718000000_add_user_id_to_staff.sql` (new)
2. `supabase/migrations/20260718000001_add_gps_to_sites.sql` (new)
3. `supabase/migrations/20260718000002_add_email_to_staff.sql` (new)
4. `src/hooks/useOfficerAssignments.ts`
5. `src/components/patrol/OfficerClockScreen.tsx`
6. `src/components/shared/SiteSelector.tsx`
7. `src/integrations/supabase/types.ts`

**Next Step:** Apply migrations via Lovable Cloud → Database → SQL Editor