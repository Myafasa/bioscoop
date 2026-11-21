# Bioscoop

MVP sistem booking tiket bioskop multi-tenant. Tahap awal menyediakan scaffold Next.js, Prisma, skema PostgreSQL dengan RLS, serta data demo.

## Prasyarat

- Node.js 20 atau lebih baru
- PostgreSQL 16
- Role PostgreSQL administrator untuk menyiapkan role aplikasi dan migrasi

## Menyiapkan database lokal

1. Buat database bernama `bioscoop`.
2. Dari koneksi administrator ke database itu, jalankan `prisma/bootstrap-roles.sql` dengan variabel psql `app_password` dan `migrator_password`. Role `bioscoop_migrator` menjalankan migrasi; `bioscoop_app` dipakai aplikasi dan tidak memiliki hak superuser atau kepemilikan tabel.
3. Salin `.env.example` menjadi `.env`, lalu isi kedua URL database dengan kredensial yang sesuai.
4. Jalankan `npm install`, `npm run db:generate`, `npm run db:migrate`, dan `npm run db:seed`.
5. Jalankan `npm run dev`.

Seed membuat tenant `mentari` dan `bintang`. Kata sandi demo semua akun adalah `BioscoopDemo123!`. Email akun: `admin@{tenant}.localhost`, `kasir@{tenant}.localhost`, dan `pelanggan@{tenant}.localhost`.

Subdomain `*.localhost` digunakan oleh browser modern untuk pengembangan lokal; routing tenant akan ditambahkan di tahap 2.

## Status tahapan

- [x] Tahap 1: scaffold, schema, migrasi RLS dan indeks kursi, seed.
- [ ] Tahap 2: middleware tenant, helper transaksi, autentikasi dan role.
- [ ] Tahap 3–7: fitur aplikasi dan deployment.
