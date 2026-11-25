import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";

const BLOCKED_FILES = [".env", ".env.local", ".env.production", ".env.staging", "secrets.json"];

function isSensitive(path: string): boolean {
  const filename = path.split("/").pop() ?? "";
  return BLOCKED_FILES.some((b) => filename === b);
}

function commandReferencesSensitiveFile(command: string): boolean {
  return BLOCKED_FILES.some((b) => command.includes(b));
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (isToolCallEventType("read", event) && isSensitive(event.input.path)) {
      return { block: true, reason: `Blocked: ${event.input.path} is sensitive` };
    }

    if (isToolCallEventType("edit", event) && isSensitive(event.input.path)) {
      return { block: true, reason: `Blocked: ${event.input.path} is sensitive` };
    }

    if (isToolCallEventType("write", event) && isSensitive(event.input.path)) {
      return { block: true, reason: `Blocked: ${event.input.path} is sensitive` };
    }

    if (isToolCallEventType("bash", event) && commandReferencesSensitiveFile(event.input.command)) {
      return { block: true, reason: `Blocked: command references sensitive file` };
    }
  });
}
