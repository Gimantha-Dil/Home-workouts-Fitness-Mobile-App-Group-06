-- ============================================================================
-- Supabase Storage Configuration for FitPulse Mobile Application
-- ============================================================================
-- NOTE: In this architecture, authentication is managed by Firebase Auth.
-- Supabase receives client requests using the `anon` public key role.
--
-- SECURITY TRADE-OFF NOTE:
-- Using `anon` role for storage uploads permits signed-in app clients to upload
-- directly to storage buckets. The stricter production setup requires configuring
-- Supabase "Third-Party Auth" with Firebase JWT verification, or using server-side
-- edge functions to mint scoped upload tokens.
-- ============================================================================

-- 1. CREATE BUCKETS WITH SIZE AND MIME CONSTRAINTS

-- Public bucket for User Profile Photos (max 5 MB)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'user-photos',
  'user-photos',
  true,
  5242880, -- 5 MB
  array['image/jpeg', 'image/png', 'image/webp']
) on conflict (id) do update set
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp'];

-- Public bucket for Exercise Routine Videos (max 50 MB)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'exercise-videos',
  'exercise-videos',
  true,
  52428800, -- 50 MB
  array['video/mp4']
) on conflict (id) do update set
  public = true,
  file_size_limit = 52428800,
  allowed_mime_types = array['video/mp4'];

-- Private bucket for Trainer / Advisor Verification Documents (max 10 MB)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'verification-docs',
  'verification-docs',
  false, -- Private bucket; accessed only via Signed URLs
  10485760, -- 10 MB
  array['application/pdf', 'image/jpeg', 'image/png']
) on conflict (id) do update set
  public = false,
  file_size_limit = 10485760,
  allowed_mime_types = array['application/pdf', 'image/jpeg', 'image/png'];

-- 2. RLS STORAGE OBJECT POLICIES FOR ROLE `anon`

-- Enable RLS on storage.objects
alter table storage.objects enable row level security;

-- Policy A: Allow anon INSERT into all three storage buckets
create policy "Allow anon upload to user-photos, exercise-videos, verification-docs"
on storage.objects for insert
to anon
with check (
  bucket_id in ('user-photos', 'exercise-videos', 'verification-docs')
);

-- Policy B: Allow anon SELECT (read) for public buckets ONLY (user-photos, exercise-videos)
create policy "Allow anon public read for user-photos and exercise-videos"
on storage.objects for select
to anon
using (
  bucket_id in ('user-photos', 'exercise-videos')
);

-- Policy C: NO UPDATE or DELETE policies created for anon role (prevents tampering)
-- Policy D: NO SELECT policy created for verification-docs bucket for anon role
-- (Verification documents are strictly accessed via time-limited Signed URLs generated on upload).
