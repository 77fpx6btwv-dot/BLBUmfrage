-- Lernband-Erhebung: Einrichtung in Supabase
-- Ausführen: Dashboard → SQL Editor → New query → einfügen → Run
-- VORHER die zwei Platzhalter unten (DEINE@MAIL und CODE) ersetzen.

-- 1) Tabellen -----------------------------------------------------------
create table if not exists public.antworten (
  id         bigint generated always as identity primary key,
  tag        date  not null default current_date,      -- bewusst nur Datum, keine Uhrzeit
  gruppe     text  not null check (gruppe in ('s','e','l')),
  antworten  jsonb not null check (jsonb_typeof(antworten) = 'object'
                                   and octet_length(antworten::text) < 30000)
);

create table if not exists public.einstellungen (
  key   text primary key,
  value text not null
);

-- 2) Zugriffsschutz (Row Level Security) ------------------------------
alter table public.antworten     enable row level security;
alter table public.einstellungen enable row level security;

revoke all on public.antworten     from anon, authenticated;
revoke all on public.einstellungen from anon, authenticated;
grant select on public.antworten to authenticated;       -- zusätzlich durch Policy auf Auswerter begrenzt

-- 3) Einstellungen -------------------------------------------------------
insert into public.einstellungen (key, value) values
  ('auswerter_email', 'DEINE@MAIL'),     -- nur dieser Login darf Antworten lesen
  ('zugangscode',     'CODE')            -- leer lassen ('') = kein Code nötig
on conflict (key) do update set value = excluded.value;

-- 4) Wer darf lesen? ---------------------------------------------------
create or replace function public.ist_auswerter()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.einstellungen
    where key = 'auswerter_email'
      and lower(value) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

drop policy if exists "nur Auswerter lesen" on public.antworten;
create policy "nur Auswerter lesen" on public.antworten
  for select to authenticated using (public.ist_auswerter());

-- 5) Absenden: einzige Schreibmöglichkeit für anonyme Besucher ----------
create or replace function public.antwort_abschicken(p_gruppe text, p_antworten jsonb, p_code text default null)
returns void language plpgsql security definer set search_path = public as $$
declare v_code text;
begin
  select value into v_code from public.einstellungen where key = 'zugangscode';
  if coalesce(v_code, '') <> '' and lower(trim(coalesce(p_code, ''))) <> lower(trim(v_code)) then
    raise exception 'Zugangscode falsch';
  end if;
  insert into public.antworten (gruppe, antworten) values (p_gruppe, p_antworten);
end $$;

revoke all on function public.antwort_abschicken(text, jsonb, text) from public;
grant execute on function public.antwort_abschicken(text, jsonb, text) to anon, authenticated;
