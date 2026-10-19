import { createFileRoute } from "@tanstack/react-router";
import { Pit } from "@/components/playground/Pit";

export const Route = createFileRoute("/")({ component: Pit });
