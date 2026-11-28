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
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !anonKey || !serviceRoleKey) {
      return jsonResponse({ error: "Server configuration missing" }, 500);
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "Missing Authorization header" }, 401);
    }

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const { data: authData, error: authErr } = await userClient.auth.getUser();
    if (authErr || !authData.user) {
      return jsonResponse({ error: "Unauthorized" }, 401);
    }
    const callerId = authData.user.id;

    // Verify caller is an admin in public.profiles (never trust user_metadata)
    const { data: callerProfile, error: profileErr } = await adminClient
      .from("profiles")
      .select("role")
      .eq("id", callerId)
      .single();

    if (profileErr || callerProfile?.role !== "admin") {
      return jsonResponse({ error: "Forbidden: Admin access required" }, 403);
    }

    const body = await req.json();
    const action = body?.action as string | undefined;

    if (action === "create_user") {
      const email = String(body.email ?? "").trim().toLowerCase();
      const password = String(body.password ?? "");
      const displayName = String(body.display_name ?? "").trim();
      const role = String(body.role ?? "student").trim();
      const schoolName = body.school_name ? String(body.school_name).trim() : null;
      const className = body.class_name ? String(body.class_name).trim() : null;
      const courseId =
        role === "teacher" && body.course_id ? String(body.course_id).trim() : null;

      if (!email || !password || password.length < 6 || !displayName) {
        return jsonResponse(
          { error: "Email, nama, dan password (min. 6 karakter) wajib diisi." },
          400
        );
      }
      if (!["student", "teacher", "admin"].includes(role)) {
        return jsonResponse({ error: "Role tidak valid." }, 400);
      }

      const { data: created, error: createErr } =
        await adminClient.auth.admin.createUser({
          email,
          password,
          email_confirm: true,
        });

      if (createErr || !created.user) {
        return jsonResponse(
          { error: createErr?.message ?? "Gagal membuat akun auth." },
          400
        );
      }

      const { data: newProfile, error: insertErr } = await adminClient
        .from("profiles")
        .upsert({
          id: created.user.id,
          email,
          display_name: displayName,
          role,
          language_pref: "id",
          school_name: schoolName,
          class_name: className,
          course_id: courseId,
        })
        .select()
        .single();

      if (insertErr) {
        await adminClient.auth.admin.deleteUser(created.user.id);
        return jsonResponse({ error: insertErr.message }, 400);
      }

      return jsonResponse({ ok: true, profile: newProfile });
    }

    if (action === "update_role") {
      const userId = String(body.user_id ?? "").trim();
      const role = String(body.role ?? "").trim();
      const courseId =
        role === "teacher" && body.course_id ? String(body.course_id).trim() : null;

      if (!userId || !["student", "teacher", "admin"].includes(role)) {
        return jsonResponse({ error: "Parameter user_id atau role tidak valid." }, 400);
      }
      if (userId === callerId) {
        return jsonResponse({ error: "Tidak dapat mengubah role akun sendiri." }, 400);
      }

      const { data: updated, error: updateErr } = await adminClient
        .from("profiles")
        .update({ role, course_id: courseId })
        .eq("id", userId)
        .select()
        .single();

      if (updateErr) {
        return jsonResponse({ error: updateErr.message }, 400);
      }

      return jsonResponse({ ok: true, profile: updated });
    }

    if (action === "delete_user") {
      const userId = String(body.user_id ?? "").trim();
      if (!userId) {
        return jsonResponse({ error: "Parameter user_id wajib diisi." }, 400);
      }
      if (userId === callerId) {
        return jsonResponse({ error: "Tidak dapat menghapus akun sendiri." }, 400);
      }

      const { error: delErr } = await adminClient.auth.admin.deleteUser(userId);
      if (delErr) {
        return jsonResponse({ error: delErr.message }, 400);
      }

      return jsonResponse({ ok: true });
    }

    return jsonResponse({ error: "Unknown action" }, 400);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return jsonResponse({ error: message }, 500);
  }
});
