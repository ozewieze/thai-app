supabase
      .from("language_notes")
      .select(
        `
        id,
        title,
        display_order,
        language_note_blocks (
          id,
          display_order,
          block_type,
          heading,
          content,
          language_note_examples (
            id,
            display_order,
            thai_script,
            paiboon,
            translation_en,
            audio_url,
            voice_key
          )
        )
      `,
      )
      .eq("lesson_id", lessonId)
      .order("display_order", { ascending: true });