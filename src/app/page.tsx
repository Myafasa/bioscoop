export default function Home() {
  return (
    <main className="mx-auto flex min-h-screen max-w-5xl flex-col justify-center px-6 py-20">
      <p className="mb-4 text-sm font-semibold uppercase tracking-[0.24em] text-amber-400">Bioscoop</p>
      <h1 className="max-w-3xl text-5xl font-bold tracking-tight sm:text-6xl">Pesan kursi. Nikmati filmnya.</h1>
      <p className="mt-6 max-w-xl text-lg leading-8 text-zinc-400">Platform tiket bioskop yang membantu setiap jaringan mengelola jadwal dan penjualan dengan mudah.</p>
      <div className="mt-10 rounded-xl border border-white/10 bg-white/5 p-5 text-sm text-zinc-300">
        Halaman tenant akan tersedia melalui subdomain bioskop masing-masing.
      </div>
    </main>
  );
}
