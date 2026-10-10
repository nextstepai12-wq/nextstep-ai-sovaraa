-- شغّل هذا الملف كاملاً في Supabase: SQL Editor ← New query ← Run
-- 1) غيّر البريد التالي إلى بريد الأدمن (نفس البريد الذي ستنشئ له مستخدماً في Authentication)
-- 2) غيّر وقت الإغلاق إن لزم (التوقيت العالمي UTC)

create table if not exists public.ambassador_applications (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  full_name text not null,
  gender text not null check (gender in ('male','female')),
  birth_year int,
  phone text not null,
  email text not null unique,
  city text,
  university text not null,
  major text not null,
  study_level text not null,
  gpa text,
  social_link text,
  experience text,
  motivation text not null,
  ideas text,
  skills text[],
  weekly_hours text,
  photo_path text,
  status text not null default 'new' check (status in ('new','review','interview','accepted','rejected')),
  admin_note text
);

alter table public.ambassador_applications enable row level security;

-- الطالب: يستطيع التسجيل فقط (لا يقرأ ولا يعدّل) وقبل موعد الإغلاق
create policy "students can apply" on public.ambassador_applications
  for insert to anon
  with check (status = 'new' and now() < timestamptz '2026-10-13 20:59:00+00');

-- الأدمن: صلاحية كاملة
create policy "admin full access" on public.ambassador_applications
  for all to authenticated
  using ((auth.jwt() ->> 'email') = 'nextstepai12@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'nextstepai12@gmail.com');

-- مخزن الصور (خاص)
insert into storage.buckets (id, name, public) values ('ambassador-photos','ambassador-photos', false)
on conflict (id) do nothing;

create policy "students upload photo" on storage.objects
  for insert to anon with check (bucket_id = 'ambassador-photos');

create policy "admin reads photos" on storage.objects
  for select to authenticated
  using (bucket_id = 'ambassador-photos' and (auth.jwt() ->> 'email') = 'nextstepai12@gmail.com');
