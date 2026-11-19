-- 0002: hapus kolom weight dari criteria (19 Nov 2026).
-- Meter Paham dihitung bobot sama rata sejak fix teach-turn (commit c7a0a27c),
-- kolom weight sudah tidak dipakai di mana pun. Semua nilai lama = 1
-- (terverifikasi di live DB: 24/24 kriteria berbobot 1), jadi tidak ada
-- data bermakna yang hilang.
alter table public.criteria drop column if exists weight;
