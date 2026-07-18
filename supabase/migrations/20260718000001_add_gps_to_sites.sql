-- Add GPS and geofence columns to sites table (not clients)
-- Each site has its own location, which makes more sense for geofencing

ALTER TABLE public.sites
ADD COLUMN IF NOT EXISTS gps_lat DECIMAL(10, 8),
ADD COLUMN IF NOT EXISTS gps_lng DECIMAL(11, 8),
ADD COLUMN IF NOT EXISTS geofence_radius_meters INTEGER DEFAULT 50;

-- Create index for spatial queries if needed
CREATE INDEX IF NOT EXISTS idx_sites_gps ON public.sites(gps_lat, gps_lng);

-- Update existing sites to parse gps_coordinates if column exists
-- gps_coordinates format: "lat,lng" or "POINT(lat lng)" or "lat, lng"
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'sites' AND column_name = 'gps_coordinates'
  ) THEN
    UPDATE public.sites
    SET
      gps_lat = CAST(
        TRIM(
          REPLACE(
            REPLACE(SPLIT_PART(gps_coordinates, ',', 1), 'POINT(', ''),
            '(', ''
          )
        ) AS DECIMAL(10, 8)
      ),
      gps_lng = CAST(
        TRIM(
          REPLACE(
            REPLACE(SPLIT_PART(gps_coordinates, ',', 2), ')', ''),
            ' ', ''
          )
        ) AS DECIMAL(11, 8)
      )
    WHERE gps_coordinates IS NOT NULL
      AND gps_coordinates LIKE '%,%'
      AND (gps_lat IS NULL OR gps_lng IS NULL);
  END IF;
END $$;