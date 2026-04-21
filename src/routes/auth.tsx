import { createFileRoute } from "@tanstack/react-router";
import AuthPage from "@/pages/auth";

export const Route = createFileRoute("/auth")({
  head: () => ({
    meta: [
      { title: "Sign in — School Portal" },
      { name: "description", content: "Sign in or create your school portal account." },
    ],
  }),
  component: AuthPage,
});
