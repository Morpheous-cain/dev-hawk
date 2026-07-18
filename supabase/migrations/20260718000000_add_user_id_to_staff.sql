-- Add user_id column to staff table to link with auth.users
-- This enables the useOfficerAssignments hook to find staff records by auth user ID

ALTER TABLE public.staff
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_staff_user_id ON public.staff(user_id);

-- Update RLS policies to allow staff to see their own record via user_id
DROP POLICY IF EXISTS "Staff can view own record" ON public.staff;
CREATE POLICY "Staff can view own record"
  ON public.staff FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_elevated_user(auth.uid()));

-- Allow staff to update their own record (limited fields)
DROP POLICY IF EXISTS "Staff can update own record" ON public.staff;
CREATE POLICY "Staff can update own record"
  ON public.staff FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid() OR public.is_elevated_user(auth.uid()))
  WITH CHECK (user_id = auth.uid() OR public.is_elevated_user(auth.uid()));

-- Enable realtime for staff table (already in supabase_realtime publication)
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.staff;