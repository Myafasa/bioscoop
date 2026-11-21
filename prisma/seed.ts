import { PrismaClient, MembershipRole, TenantPlan } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash("BioscoopDemo123!", 10);
  const fixtures = [
    {
      nama: "Bioskop Mentari", subdomain: "mentari", plan: TenantPlan.PRO,
      users: [
        { nama: "Admin Mentari", email: "admin@mentari.localhost", role: MembershipRole.TENANT_ADMIN },
        { nama: "Kasir Mentari", email: "kasir@mentari.localhost", role: MembershipRole.CASHIER },
        { nama: "Pelanggan Mentari", email: "pelanggan@mentari.localhost", role: MembershipRole.CUSTOMER },
      ],
      movie: { judul: "Petualangan Senja", durasiMenit: 112, sinopsis: "Sebuah perjalanan pulang yang mengubah segalanya." },
    },
    {
      nama: "Bioskop Bintang", subdomain: "bintang", plan: TenantPlan.BASIC,
      users: [
        { nama: "Admin Bintang", email: "admin@bintang.localhost", role: MembershipRole.TENANT_ADMIN },
        { nama: "Kasir Bintang", email: "kasir@bintang.localhost", role: MembershipRole.CASHIER },
        { nama: "Pelanggan Bintang", email: "pelanggan@bintang.localhost", role: MembershipRole.CUSTOMER },
      ],
      movie: { judul: "Orbit Terakhir", durasiMenit: 128, sinopsis: "Misi terakhir manusia menuju planet baru." },
    },
  ];

  for (const fixture of fixtures) {
    const tenant = await prisma.tenant.upsert({
      where: { subdomain: fixture.subdomain },
      update: { nama: fixture.nama, plan: fixture.plan, aktif: true },
      create: { nama: fixture.nama, subdomain: fixture.subdomain, plan: fixture.plan },
    });
    await prisma.$transaction(async (tx) => {
      // Seed tenant data through the same RLS context required by the application.
      await tx.$executeRaw`SELECT set_config('app.tenant_id', ${tenant.id}, true)`;
      const movie = await tx.movie.create({ data: {
        tenantId: tenant.id, ...fixture.movie,
      } });
      const studio = await tx.studio.create({ data: {
        tenantId: tenant.id, nama: "Studio 1", jumlahBaris: 8, jumlahKolom: 10,
      } });
      await tx.showtime.create({ data: {
        tenantId: tenant.id, movieId: movie.id, studioId: studio.id,
        mulai: new Date(Date.now() + 24 * 60 * 60 * 1000), harga: 45000,
      } });

      for (const account of fixture.users) {
        const user = await tx.user.upsert({
          where: { email: account.email },
          update: { nama: account.nama, passwordHash },
          create: { email: account.email, nama: account.nama, passwordHash },
        });
        await tx.membership.upsert({
          where: { tenantId_userId: { tenantId: tenant.id, userId: user.id } },
          update: { role: account.role },
          create: { tenantId: tenant.id, userId: user.id, role: account.role },
        });
      }
    });
  }
}

main()
  .then(async () => prisma.$disconnect())
  .catch(async (error: unknown) => {
    console.error(error);
    await prisma.$disconnect();
    process.exitCode = 1;
  });
