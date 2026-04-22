import { supabase } from "@/lib/supabase";

export default async function SupabaseTestPage() {
  const { data, error } = await supabase
    .from("lesson_grammar")
    .select("id, lesson_id, grammar_id")
    .limit(5);

  return (
    <main style={{ padding: "24px", fontFamily: "Arial, sans-serif" }}>
      <h1>Supabase lokale test</h1>

      {error ? (
        <pre style={{ color: "crimson", whiteSpace: "pre-wrap" }}>
          {JSON.stringify(error, null, 2)}
        </pre>
      ) : (
        <pre style={{ background: "#f4f4f4", padding: "16px" }}>
          {JSON.stringify(data, null, 2)}
        </pre>
      )}
    </main>
  );
}
