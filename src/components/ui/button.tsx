import type { ButtonHTMLAttributes } from "react";
import { cn } from "@/lib/utils";

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "default" | "outline" | "ghost";
};

export function Button({ className, variant = "default", ...props }: ButtonProps) {
  const variants = {
    default: "bg-amber-400 text-zinc-950 hover:bg-amber-300",
    outline: "border border-white/15 bg-transparent hover:bg-white/10",
    ghost: "bg-transparent hover:bg-white/10",
  };

  return <button className={cn("inline-flex items-center justify-center rounded-md px-4 py-2 text-sm font-medium transition-colors disabled:pointer-events-none disabled:opacity-50", variants[variant], className)} {...props} />;
}
