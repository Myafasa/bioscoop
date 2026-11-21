import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Bioscoop — Sistem Booking Tiket",
  description: "Platform booking tiket bioskop multi-tenant.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="id"><body>{children}</body></html>;
}
