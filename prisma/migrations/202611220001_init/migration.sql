CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE "TenantPlan" AS ENUM ('BASIC', 'PRO', 'ENTERPRISE');
CREATE TYPE "MembershipRole" AS ENUM ('TENANT_ADMIN', 'CASHIER', 'CUSTOMER');
CREATE TYPE "BookingStatus" AS ENUM ('PENDING', 'PAID', 'EXPIRED', 'CANCELLED');
CREATE TYPE "BookingSeatStatus" AS ENUM ('HELD', 'SOLD', 'RELEASED');

CREATE TABLE tenants (
  id UUID PRIMARY KEY,
  nama TEXT NOT NULL,
  subdomain TEXT NOT NULL UNIQUE,
  plan "TenantPlan" NOT NULL DEFAULT 'BASIC',
  aktif BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  nama TEXT NOT NULL
);
CREATE TABLE memberships (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role "MembershipRole" NOT NULL,
  UNIQUE (tenant_id, user_id),
  UNIQUE (tenant_id, id)
);
CREATE TABLE movies (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  judul TEXT NOT NULL,
  durasi_menit INTEGER NOT NULL,
  sinopsis TEXT NOT NULL,
  poster_url TEXT,
  UNIQUE (tenant_id, id)
);
CREATE TABLE studios (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nama TEXT NOT NULL,
  jumlah_baris INTEGER NOT NULL,
  jumlah_kolom INTEGER NOT NULL,
  UNIQUE (tenant_id, id)
);
CREATE TABLE showtimes (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  movie_id UUID NOT NULL,
  studio_id UUID NOT NULL,
  mulai TIMESTAMPTZ(6) NOT NULL,
  harga INTEGER NOT NULL,
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, movie_id) REFERENCES movies(tenant_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (tenant_id, studio_id) REFERENCES studios(tenant_id, id) ON DELETE RESTRICT
);
CREATE TABLE bookings (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  showtime_id UUID NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  kode TEXT NOT NULL UNIQUE,
  status "BookingStatus" NOT NULL DEFAULT 'PENDING',
  expires_at TIMESTAMPTZ(6) NOT NULL,
  total INTEGER NOT NULL,
  dibuat_pada TIMESTAMPTZ(6) NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, showtime_id) REFERENCES showtimes(tenant_id, id) ON DELETE RESTRICT
);
CREATE TABLE booking_seats (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  booking_id UUID NOT NULL,
  showtime_id UUID NOT NULL,
  kode_kursi TEXT NOT NULL,
  status "BookingSeatStatus" NOT NULL DEFAULT 'HELD',
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, booking_id) REFERENCES bookings(tenant_id, id) ON DELETE CASCADE,
  FOREIGN KEY (tenant_id, showtime_id) REFERENCES showtimes(tenant_id, id) ON DELETE RESTRICT
);
CREATE TABLE tickets (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  booking_id UUID NOT NULL,
  kode TEXT NOT NULL UNIQUE,
  used_at TIMESTAMPTZ(6),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, booking_id) REFERENCES bookings(tenant_id, id) ON DELETE CASCADE
);

CREATE INDEX showtimes_tenant_mulai_idx ON showtimes(tenant_id, mulai);
CREATE INDEX bookings_expiry_idx ON bookings(tenant_id, status, expires_at);
-- Constraint ini menangani tabrakan lintas replika; RELEASED tidak lagi memblokir kursi.
CREATE UNIQUE INDEX booking_seats_active_showtime_seat_key
  ON booking_seats(showtime_id, kode_kursi)
  WHERE status IN ('HELD', 'SOLD');

ALTER TABLE memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE memberships FORCE ROW LEVEL SECURITY;
CREATE POLICY memberships_tenant_isolation ON memberships
  USING (tenant_id = current_setting('app.tenant_id')::uuid)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::uuid);

ALTER TABLE movies ENABLE ROW LEVEL SECURITY;
ALTER TABLE movies FORCE ROW LEVEL SECURITY;
CREATE POLICY movies_tenant_isolation ON movies
  USING (tenant_id = current_setting('app.tenant_id')::uuid)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::uuid);

ALTER TABLE studios ENABLE ROW LEVEL SECURITY;
ALTER TABLE studios FORCE ROW LEVEL SECURITY;
CREATE POLICY studios_tenant_isolation ON studios
  USING (tenant_id = current_setting('app.tenant_id')::uuid)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::uuid);

ALTER TABLE showtimes ENABLE ROW LEVEL SECURITY;
ALTER TABLE showtimes FORCE ROW LEVEL SECURITY;
CREATE POLICY showtimes_tenant_isolation ON showtimes
  USING (tenant_id = current_setting('app.tenant_id')::uuid)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::uuid);

ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings FORCE ROW LEVEL SECURITY;
CREATE POLICY bookings_tenant_isolation ON bookings
  USING (tenant_id = current_setting('app.tenant_id')::uuid)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::uuid);

ALTER TABLE booking_seats ENABLE ROW LEVEL SECURITY;
ALTER TABLE booking_seats FORCE ROW LEVEL SECURITY;
CREATE POLICY booking_seats_tenant_isolation ON booking_seats
  USING (tenant_id = current_setting('app.tenant_id')::uuid)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::uuid);

ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets FORCE ROW LEVEL SECURITY;
CREATE POLICY tickets_tenant_isolation ON tickets
  USING (tenant_id = current_setting('app.tenant_id')::uuid)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::uuid);

-- Role aplikasi tidak memiliki tabel, sehingga FORCE RLS tetap berlaku.
GRANT USAGE ON SCHEMA public TO bioscoop_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON tenants, users, memberships, movies, studios,
  showtimes, bookings, booking_seats, tickets TO bioscoop_app;
