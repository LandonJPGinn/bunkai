/// Local display labels and study tips keyed by [QuizQuestion.diagnosticTags].
class DiagnosticTagRecommendations {
  const DiagnosticTagRecommendations._();

  static const String fallbackRecommendation =
      'Revisit questions tagged with this skill and read each explanation slowly.';

  static const Map<String, String> displayNames = {
    'wo_ga': 'を vs が',
    'ni_de': 'に vs で',
    'wa_ga': 'は vs が',
  };

  static const Map<String, String> recommendations = {
    'particle_choice':
        'Review what each particle marks semantically, not just its English translation.',
    'wa_ga':
        'Practice distinguishing new information with が from topic or contrast with は.',
    'modifier_scope':
        'Slow down and identify the final noun that each clause modifies.',
    'omitted_subject':
        'Use dialogue turns and verb direction to infer who is acting.',
    'register':
        'Compare the relationship, setting, and request size before choosing an expression.',
    'transitivity':
        'Ask whether the subject changes by itself or someone acts on the object.',
    'verb_conjugation':
        'Group verbs by ichidan, godan, and irregular before transforming forms.',
    'ni_de':
        'Review に for target, time, existence vs で for means, place of action, or scope.',
    'wo':
        'Practice transitive frames: who acts (が) and what is affected (を).',
    'topic_contrast':
        'Work on sentences that switch topic with は while keeping が for new information.',
    'relative_clause':
        'Isolate modifying clauses and confirm what they modify before choosing an answer.',
    'sentence_parsing':
        'Slow down and bracket clauses before deciding who did what to whom.',
    'noun_modification':
        'Check whether a clause is restrictive or descriptive for the noun it follows.',
    'dialogue_context':
        'Reread the prior line in dialogue; Japanese often drops what context already supplies.',
    'omitted_object':
        'Recover the object from earlier turns when the verb still implies a patient.',
    'implication':
        'Note indirect refusals, soft agreements, and what is left unsaid.',
    'politeness':
        'Pair honorific/humble verbs with the right subject and add softeners where needed.',
    'directness':
        'Soften requests or opinions in formal contexts; be more direct only when safe.',
    'keigo':
        'Review honorific vs humble pairs and who each verb elevates or lowers.',
    'casual_speech':
        'Notice contractions, dropped particles, and peer-only phrasing.',
    'jidoushi':
        'Prefer が + intransitive when the thing itself changes state without an agent.',
    'tadoushi':
        'Prefer を + transitive when a person or agent performs the action on something.',
    'wo_ga':
        'Practice を vs が frames with the same verb stem in different readings.',
    'intention':
        'Decide whether the sentence describes intent to act (他動詞) vs resulting state (自動詞).',
    'te_form':
        'Review て形 sound changes for godan verbs and irregular いく／くる.',
    'nai_form':
        'Practice ない stem changes and polite ません.',
    'masu_form':
        'Check stem + ます for statements and invitations before other endings.',
    'past_form':
        'Contrast た for completed events vs ます past in polite narratives.',
    'potential_form':
        'Rehearse られる／できる and the “can / is able” nuance with particles.',
    'passive_form':
        'Separate られる (passive / spontaneous) from させる (causative) before picking the stem.',
    'causative_form':
        'Track who causes the action: せる for godan, させる for ichidan, さす for す.',
    'volitional_form':
        'Drill 五段 o-row + う and 一段 よう; don’t mix them with ます stem.',
    'conditional_ba_form':
        'Build え段＋ば for godan; ければ for ichidan; watch は／へ irregulars.',
    'tara_form':
        'たら attaches to past stem (いた／った／した／きた); contrast temporal vs conditional readings.',
    'imperative_form':
        'Know 五段 e-row imperatives vs 一段ろ／よ imperatives and irregular しろ／こい.',
    'prohibitive_form':
        'Attach な to the dictionary form only; don’t use the ます stem.',
    'dictionary_form':
        'Strip ます from the polite stem and restore any vowel change (e.g. き／み stems).',
  };

  static String humanizeTag(String tag) =>
      displayNames[tag] ?? tag.replaceAll('_', ' ');

  static String recommendationFor(String tag) =>
      recommendations[tag] ?? fallbackRecommendation;
}
