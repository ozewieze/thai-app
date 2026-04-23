import { supabase } from "@/lib/supabase";

export default async function SupabaseTestPage() {
  const { data, error } = await supabase
    .from("vocabulary_master")
    .select("id, source_key, thai_script, english_gloss")
    .limit(10);

  if (error) {
    return <pre>{error.message}</pre>;
  }

  return (
    <main style={{ padding: "24px", fontFamily: "Arial, sans-serif" }}>
      <h1>Supabase lokale test 2</h1>

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
