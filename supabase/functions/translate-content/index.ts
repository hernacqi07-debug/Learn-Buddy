import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "Missing Authorization header" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const {
      data: { user },
      error: authErr,
    } = await userClient.auth.getUser();

    if (authErr || !user) {
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    const admin = createClient(supabaseUrl, serviceRoleKey);
    const { data: profile } = await admin
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();

    if (profile?.role !== "teacher") {
      return jsonResponse({ error: "Teacher access only" }, 403);
    }

    const body = await req.json();
    const apiKey = Deno.env.get("LLM_API_KEY");
    const model = Deno.env.get("LLM_MODEL") ?? "gemini-2.5-flash";
    const baseUrl =
      Deno.env.get("LLM_BASE_URL") ??
      "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions";

    if (!apiKey) {
      return jsonResponse({ error: "LLM_API_KEY is not configured" }, 500);
    }

    const prompt = `You are a technical translator for an Indonesian Data Structures mobile learning app ("Learn Buddy") aimed at vocational high school (SMK) students.
Translate the following Indonesian learning content into natural, clear, accurate English.
Keep standard Data Structures terminology (e.g. Stack, LIFO, push, pop, Linked List, node, pointer, head).
Return ONLY valid JSON matching the exact input structure with English translations.

Input JSON:
${JSON.stringify({
  misconception_text: body?.misconception_text ?? "",
  correct_concept: body?.correct_concept ?? "",
  buddy_intro: body?.buddy_intro ?? "",
  criteria: Array.isArray(body?.criteria) ? body.criteria : [],
})}

Output JSON schema:
{
  "misconception_text_en": "...",
  "correct_concept_en": "...",
  "buddy_intro_en": "...",
  "criteria_en": [
    { "id": "<same id or index>", "criterion_text_en": "..." }
  ]
}`;

    const res = await fetch(baseUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model,
        messages: [{ role: "system", content: prompt }],
        temperature: 0,
        max_tokens: 900,
        response_format: { type: "json_object" },
      }),
    });

    if (!res.ok) {
      const errText = await res.text();
      return jsonResponse(
        { error: `Translation failed (${res.status}): ${errText.slice(0, 200)}` },
        502,
      );
    }

    const data = await res.json();
    const raw = String(data?.choices?.[0]?.message?.content ?? "")
      .trim()
      .replace(/^```json\s*/i, "")
      .replace(/^```\s*/i, "")
      .replace(/```\s*$/i, "")
      .trim();

    const parsed = JSON.parse(raw);
    return jsonResponse(parsed);
  } catch (err) {
    console.error("translate-content error:", err);
    return jsonResponse({ error: "Translation error" }, 500);
  }
});
