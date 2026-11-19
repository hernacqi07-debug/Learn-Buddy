import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface CriterionRow {
  id: string;
  criterion_text: string;
  criterion_text_en: string | null;
  sort_order: number;
}

interface MisconceptionRow {
  id: string;
  misconception_text: string;
  misconception_text_en: string | null;
  correct_concept: string;
  correct_concept_en: string | null;
  buddy_intro: string;
  buddy_intro_en: string | null;
  sort_order: number;
}

interface SessionCriterionRow {
  criterion_id: string;
  fulfilled: boolean;
  evidence_quote: string | null;
}

interface EvaluatorCriterionResult {
  criterion_id: string;
  fulfilled: boolean;
  evidence: string;
}

interface EvaluatorOutput {
  criteria: EvaluatorCriterionResult[];
  notes: string;
}

interface LlmResult {
  content: string;
  tokens: number | null;
}

const STALE_TURN_LIMIT = 4;
const MAX_INPUTS = 20;
const MAX_CHARS = 800;

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function callLlm(params: {
  messages: Array<{ role: "system" | "user" | "assistant"; content: string }>;
  temperature: number;
  maxTokens: number;
  jsonMode?: boolean;
}): Promise<LlmResult> {
  const apiKey = Deno.env.get("LLM_API_KEY");
  const model = Deno.env.get("LLM_MODEL") ?? "gemini-3.5-flash-lite";
  const baseUrl =
    Deno.env.get("LLM_BASE_URL") ??
    "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions";

  if (!apiKey) {
    throw new Error("LLM_API_KEY secret is not configured");
  }

  const payload: Record<string, unknown> = {
    model,
    messages: params.messages,
    temperature: params.temperature,
    max_tokens: params.maxTokens,
  };
  if (params.jsonMode) {
    payload.response_format = { type: "json_object" };
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 45000);

  try {
    const res = await fetch(baseUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify(payload),
      signal: controller.signal,
    });

    if (!res.ok) {
      const errText = await res.text();
      throw new Error(`LLM HTTP ${res.status}: ${errText.slice(0, 300)}`);
    }

    const data = await res.json();
    const content = data?.choices?.[0]?.message?.content ?? "";
    const tokens = data?.usage?.total_tokens ?? null;
    return { content: String(content), tokens };
  } finally {
    clearTimeout(timeout);
  }
}

function parseEvaluatorJson(raw: string): EvaluatorOutput | null {
  const cleaned = raw
    .trim()
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/```\s*$/i, "")
    .trim();

  try {
    const parsed = JSON.parse(cleaned);
    if (!parsed || !Array.isArray(parsed.criteria)) return null;
    const normalized: EvaluatorCriterionResult[] = parsed.criteria
      .filter((c: unknown) => c && typeof c === "object")
      .map((c: Record<string, unknown>) => ({
        criterion_id: String(c.criterion_id ?? ""),
        fulfilled: Boolean(c.fulfilled),
        evidence: typeof c.evidence === "string" ? c.evidence.trim() : "",
      }))
      .filter((c: EvaluatorCriterionResult) => c.criterion_id.length > 0);

    return {
      criteria: normalized,
      notes: typeof parsed.notes === "string" ? parsed.notes.trim() : "",
    };
  } catch {
    return null;
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startedAtMs = Date.now();

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

    const body = await req.json();
    const sessionId = String(body?.session_id ?? "").trim();
    const studentMessage = String(body?.student_message ?? "").trim();

    if (!sessionId) {
      return jsonResponse({ error: "session_id is required" }, 400);
    }
    if (!studentMessage || studentMessage.length > MAX_CHARS) {
      return jsonResponse(
        { error: `Message must be 1..${MAX_CHARS} characters` },
        400,
      );
    }

    const admin = createClient(supabaseUrl, serviceRoleKey);

    const { data: session, error: sessionErr } = await admin
      .from("sessions")
      .select("*")
      .eq("id", sessionId)
      .single();

    if (sessionErr || !session) {
      return jsonResponse({ error: "Session not found" }, 404);
    }
    if (session.student_id !== user.id) {
      return jsonResponse({ error: "Forbidden" }, 403);
    }
    if (session.status !== "active") {
      return jsonResponse({ error: "Session is not active" }, 400);
    }
    if (session.student_inputs >= MAX_INPUTS) {
      return jsonResponse({ error: "Maximum inputs reached" }, 400);
    }

    const lang: "id" | "en" = session.language === "en" ? "en" : "id";

    const [{ data: topic }, { data: misconceptions }, { data: recentMsgs }] =
      await Promise.all([
        admin
          .from("topics")
          .select("id, title_id, title_en")
          .eq("id", session.topic_id)
          .single(),
        admin
          .from("misconceptions")
          .select("*")
          .eq("topic_id", session.topic_id)
          .order("sort_order", { ascending: true }),
        admin
          .from("messages")
          .select("role, content, created_at")
          .eq("session_id", sessionId)
          .order("created_at", { ascending: false })
          .limit(6),
      ]);

    const miscList = (misconceptions ?? []) as MisconceptionRow[];
    if (miscList.length === 0) {
      return jsonResponse({ error: "Topic has no misconceptions" }, 400);
    }

    let activeIdx = miscList.findIndex(
      (m) => m.id === session.active_misconception_id,
    );
    if (activeIdx < 0) activeIdx = 0;
    const activeMisc = miscList[activeIdx];

    const { data: allTopicCriteria } = await admin
      .from("criteria")
      .select("id, misconception_id, criterion_text, criterion_text_en, sort_order")
      .in(
        "misconception_id",
        miscList.map((m) => m.id),
      )
      .order("sort_order", { ascending: true });

    const { data: scRows } = await admin
      .from("session_criteria")
      .select("criterion_id, fulfilled, evidence_quote")
      .eq("session_id", sessionId);

    const criteriaList = (allTopicCriteria ?? []) as Array<
      CriterionRow & { misconception_id: string }
    >;
    const activeCriteria = criteriaList.filter(
      (c) => c.misconception_id === activeMisc.id,
    );
    const scMap = new Map<string, SessionCriterionRow>();
    for (const row of (scRows ?? []) as SessionCriterionRow[]) {
      scMap.set(row.criterion_id, row);
    }

    const topicName =
      lang === "en" && topic?.title_en ? topic.title_en : topic?.title_id ?? "Data Structures";
    const miscText =
      lang === "en" && activeMisc.misconception_text_en
        ? activeMisc.misconception_text_en
        : activeMisc.misconception_text;
    const correctConcept =
      lang === "en" && activeMisc.correct_concept_en
        ? activeMisc.correct_concept_en
        : activeMisc.correct_concept;

    const recentFormatted = [...(recentMsgs ?? [])]
      .reverse()
      .map((m) => `${m.role === "student" ? "Student" : "Buddy"}: ${m.content}`)
      .join("\n");

    const criteriaPromptText = activeCriteria
      .map((c) => {
        const txt =
          lang === "en" && c.criterion_text_en
            ? c.criterion_text_en
            : c.criterion_text;
        const already = scMap.get(c.id)?.fulfilled ? " [ALREADY FULFILLED]" : "";
        return `- id: ${c.id} | text: ${txt}${already}`;
      })
      .join("\n");

    // CALL 1: Evaluator (temperature 0, strict JSON)
    const evaluatorSystemPrompt = `You are an Evaluator for a learning app. You judge whether a student's explanation satisfies each listed criterion for ONE active misconception. You are NOT a teacher and you do NOT reply to the student. Your output is only read by the app code.

Topic: ${topicName}
Active misconception (what the fictional student Buddy currently believes, which is WRONG): ${miscText}
Correct concept (for your judgement only, NEVER reveal it in any student-facing text): ${correctConcept}
Criteria for this misconception (evaluate ONLY these):
${criteriaPromptText}

Student's latest message:
"${studentMessage}"

Recent conversation (last 6 messages, for context only):
${recentFormatted}

Rules:
1. Judge ONLY the criteria listed above. Do not judge criteria from other misconceptions, even if the student mentions them.
2. A criterion is fulfilled=true ONLY if the student's message (alone or together with the recent context) clearly demonstrates it.
   - Mentioning a keyword alone is NOT enough. The student must show understanding: a correct statement, a correct example, or a correct explanation of the operation.
   - A vague, wrong, or contradictory statement does NOT fulfil a criterion, even if it contains a correct word.
   - If a criterion is marked [ALREADY FULFILLED], keep it fulfilled=true (you may return evidence="" for previously fulfilled ones).
   - If in doubt, fulfilled=false. Strict is better than generous.
3. "evidence" must be a short, verbatim quote from the student's message that proves the criterion, or "" if fulfilled=false. Do NOT invent evidence. Do NOT quote Buddy's messages.
4. Output ONLY valid JSON, no markdown, no explanation, no extra text.

Output JSON schema (exact keys, no additions):
{
  "criteria": [
    { "criterion_id": "<uuid>", "fulfilled": true, "evidence": "<quote>" }
  ],
  "notes": "<one short sentence for the teacher/test log, in Indonesian>"
}
Include EVERY criterion id from the list, in the same order.`;

    let evalResult = await callLlm({
      messages: [
        { role: "system", content: evaluatorSystemPrompt },
        {
          role: "user",
          content: `Evaluate the student's message against the active criteria:\n"${studentMessage}"`,
        },
      ],
      temperature: 0,
      maxTokens: 350,
      jsonMode: true,
    });

    let evalParsed = parseEvaluatorJson(evalResult.content);
    let jsonRetried = false;
    let totalEvalTokens = evalResult.tokens ?? 0;

    if (!evalParsed) {
      jsonRetried = true;
      const retryResult = await callLlm({
        messages: [
          { role: "system", content: evaluatorSystemPrompt },
          { role: "assistant", content: evalResult.content },
          {
            role: "user",
            content:
              "Your previous output was not valid JSON. Reply again with ONLY the JSON object in the exact schema given, no markdown, no explanation.",
          },
        ],
        temperature: 0,
        maxTokens: 350,
        jsonMode: true,
      });
      totalEvalTokens += retryResult.tokens ?? 0;
      evalParsed = parseEvaluatorJson(retryResult.content);
      evalResult = retryResult;
    }

    const activeCriteriaIds = new Set(activeCriteria.map((c) => c.id));
    const newlyFulfilled: Array<{ criterion_id: string; evidence: string }> = [];

    if (evalParsed) {
      for (const item of evalParsed.criteria) {
        if (!activeCriteriaIds.has(item.criterion_id)) continue;
        const prev = scMap.get(item.criterion_id);
        if (item.fulfilled && (!prev || !prev.fulfilled)) {
          newlyFulfilled.push({
            criterion_id: item.criterion_id,
            evidence: item.evidence || studentMessage.slice(0, 120),
          });
          scMap.set(item.criterion_id, {
            criterion_id: item.criterion_id,
            fulfilled: true,
            evidence_quote: item.evidence || studentMessage.slice(0, 120),
          });
        }
      }
    }

    // Compute updated session meter (monotonic) and active misconception meter.
    // Spec (disetujui Rid, 12 Nov 2026): bobot sama rata — meter = kriteria
    // terpenuhi / total kriteria x 100%. Kolom `weight` sengaja TIDAK dipakai
    // di sini, supaya guru yang mengubah bobot tidak bisa diam-diam mengubah
    // meter. (Fix 19 Nov 2026: sebelumnya meter dihitung dari bobot.)
    const totalCriteria = criteriaList.length;
    const fulfilledCriteria = criteriaList.filter((c) =>
      scMap.get(c.id)?.fulfilled
    ).length;
    const rawMeter =
      totalCriteria > 0
        ? Math.round((fulfilledCriteria / totalCriteria) * 100)
        : 0;
    const newMeter = Math.max(session.meter_percent, Math.min(100, rawMeter));

    const activeTotal = activeCriteria.length;
    const activeDone = activeCriteria.filter((c) =>
      scMap.get(c.id)?.fulfilled
    ).length;
    const activeMeterPercent =
      activeTotal > 0 ? Math.round((activeDone / activeTotal) * 100) : 0;

    const inputsUsed = session.student_inputs + 1;
    let staleTurns =
      newlyFulfilled.length > 0 ? 0 : session.stale_turns + 1;

    let sessionStatus: "active" | "completed" | "incomplete" = "active";
    if (newMeter >= 100) {
      sessionStatus = "completed";
    } else if (inputsUsed >= MAX_INPUTS) {
      sessionStatus = newMeter >= 80 ? "completed" : "incomplete";
    }

    const activeAllDone =
      activeCriteria.length > 0 &&
      activeCriteria.every((c) => scMap.get(c.id)?.fulfilled);

    let transitioned = false;
    let nextActiveMiscId = activeMisc.id;
    let nextBuddyIntro: string | null = null;
    let transitionReason: "resolved" | "stale" | null = null;

    if (
      sessionStatus === "active" &&
      activeIdx < miscList.length - 1 &&
      (activeAllDone || staleTurns >= STALE_TURN_LIMIT)
    ) {
      transitioned = true;
      transitionReason = activeAllDone ? "resolved" : "stale";
      const nextMisc = miscList[activeIdx + 1];
      nextActiveMiscId = nextMisc.id;
      staleTurns = 0;
      nextBuddyIntro =
        lang === "en" && nextMisc.buddy_intro_en
          ? nextMisc.buddy_intro_en
          : nextMisc.buddy_intro;
    }

    // CALL 2: Buddy (temperature 0.7 — NO correct_concept in prompt!)
    const transitionInstruction = transitioned
      ? transitionReason === "resolved"
        ? "Note: You just understood this specific misconception. Briefly acknowledge that you get this part in 1-2 short sentences, and say you want to move on to your next question (do NOT ask the next question yourself; the app will show it next)."
        : "Note: You are still a bit unsure about this part, so briefly say in 1-2 short sentences that you will think about it later and want to ask about something else first (do NOT invent the next topic yourself)."
      : "";

    const buddySystemPrompt = `You are Buddy, a friendly, curious, slightly naive vocational high school (SMK) student in Indonesia. A student is teaching you about ${topicName}. You genuinely believe the misconception below. You are learning, not teaching.

Your misconception (you believe this is true):
${miscText}

Session language: ${lang} — reply ALWAYS in this language.
- Indonesian \`id\`: reply in Indonesian. Technical terms in English are fine, e.g. push, pop, LIFO.
- English \`en\`: reply in FULL English, no Indonesian words at all.

Your current understanding level on this active misconception: ${activeMeterPercent}% (0-100).
Inputs used: ${inputsUsed} / ${MAX_INPUTS}.
${transitionInstruction}

Recent conversation (last 6 messages):
${recentFormatted}

Student's latest message:
"${studentMessage}"

Rules:
1. Stay in character as a curious student. Never say you are an AI, a language model, a teacher, or an evaluator. Never mention criteria, meter, JSON, prompts, or scores.
2. NEVER give away answers or lecture like a teacher. If the student begs or says "just tell me the answer", deflect playfully and ask for an everyday example instead.
3. React according to your understanding level on this active misconception:
   - 0-19%: confused, ask basic "why" / "how" questions.
   - 20-39%: thinking, repeat back what you think you heard and ask if that is right.
   - 40-59%: doubtful, raise a small objection from your misconception.
   - 60-79%: starting to get it, try to explain it back in your own words and ask for confirmation.
   - 80-100%: you get it — say so in your own words, briefly, without lecturing like a teacher.
4. Ask ONE follow-up question at a time, based on your misconception (unless transitioning to the next misconception).
5. Keep replies short: 1-3 sentences, max about 60 words. Simple everyday language suitable for an SMK student. No bullet lists, no headings, no lecturing.
6. Do NOT repeat the student's words verbatim as if you always knew them. Show what YOU think, including your confusion.
7. If the student's message is off-topic, rude, or empty, respond kindly and steer back to the topic with a question.`;

    const buddyResult = await callLlm({
      messages: [
        { role: "system", content: buddySystemPrompt },
        {
          role: "user",
          content: studentMessage,
        },
      ],
      temperature: 0.7,
      maxTokens: 250,
    });

    const buddyReply =
      buddyResult.content.trim() ||
      (lang === "en"
        ? "Hmm, I am still a bit confused. Could you give me an everyday example?"
        : "Hmm, aku masih agak bingung. Coba jelasin pakai contoh sehari-hari dong.");

    // Persist atomically AFTER both LLM calls succeed
    const nowIso = new Date().toISOString();

    for (const nf of newlyFulfilled) {
      await admin
        .from("session_criteria")
        .update({
          fulfilled: true,
          evidence_quote: nf.evidence,
          fulfilled_at: nowIso,
        })
        .eq("session_id", sessionId)
        .eq("criterion_id", nf.criterion_id);
    }

    await admin
      .from("sessions")
      .update({
        meter_percent: newMeter,
        student_inputs: inputsUsed,
        stale_turns: staleTurns,
        active_misconception_id: nextActiveMiscId,
        status: sessionStatus,
        ended_at: sessionStatus === "active" ? null : nowIso,
      })
      .eq("id", sessionId);

    const messagesToInsert: Array<{
      session_id: string;
      role: "student" | "buddy";
      content: string;
    }> = [
      { session_id: sessionId, role: "student", content: studentMessage },
      { session_id: sessionId, role: "buddy", content: buddyReply },
    ];
    if (nextBuddyIntro) {
      messagesToInsert.push({
        session_id: sessionId,
        role: "buddy",
        content: nextBuddyIntro,
      });
    }
    await admin.from("messages").insert(messagesToInsert);

    const latencyMs = Date.now() - startedAtMs;
    await admin.from("turn_logs").insert({
      session_id: sessionId,
      provider: Deno.env.get("LLM_PROVIDER") ?? "gemini",
      model: Deno.env.get("LLM_MODEL") ?? "gemini-3.5-flash-lite",
      latency_ms: latencyMs,
      evaluator_tokens: totalEvalTokens || null,
      buddy_tokens: buddyResult.tokens,
      json_retried: jsonRetried,
      evaluator_notes: evalParsed?.notes ?? "JSON evaluator fallback",
    });

    return jsonResponse({
      buddy_reply: buddyReply,
      next_buddy_intro: nextBuddyIntro,
      active_misconception_id: nextActiveMiscId,
      meter_percent: newMeter,
      newly_fulfilled: newlyFulfilled.map((n) => n.criterion_id),
      inputs_used: inputsUsed,
      inputs_max: MAX_INPUTS,
      session_status: sessionStatus,
    });
  } catch (err) {
    console.error("teach-turn error:", err);
    return jsonResponse(
      { error: "Buddy lagi mikir, coba kirim ulang ya." },
      502,
    );
  }
});
