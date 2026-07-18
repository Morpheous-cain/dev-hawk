-- Add email column to staff table for matching with auth.users
-- This enables the fallback lookup by email in useOfficerAssignments hook

ALTER TABLE public.staff
ADD COLUMN IF NOT EXISTS email TEXT;

-- Create index for faster email lookups
CREATE INDEX IF NOT EXISTS idx_staff_email ON public.staff(email);

-- Update RLS policy to allow staff to update their own email
DROP POLICY IF EXISTS "Staff can update own record" ON public.staff;
CREATE POLICY "Staff can update own record"
  ON public.staff FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid() OR public.is_elevated_user(auth.uid()))
  WITH CHECK (user_id = auth.uid() OR public.is_elevated_user(auth.uid()));