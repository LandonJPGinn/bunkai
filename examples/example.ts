const cardStyle = getTopicCardStyle(topic.title);
style={{
    "--kanji": `"${kanji}"`,
    "--accent": topic.accent ?? "205 100% 62%",
    "--bg1": topic.bg1 ?? "205 92% 58%",
    "--bg2": topic.bg2 ?? "250 72% 62%",
    "--tilt": topic.tilt ?? "-4deg",
  } as React.CSSProperties}

  const topicStyleMap: Record<string, TopicCardStyle> = {
    "Particle Forensics": {
      kanji: "助",
      accent: "8 100% 65%",
      bg1: "8 95% 64%",
      bg2: "32 95% 60%",
      tilt: "-4deg",
    },
    "Clause Untangler": {
      kanji: "文",
      accent: "36 100% 58%",
      bg1: "30 94% 58%",
      bg2: "48 95% 66%",
      tilt: "3deg",
    },
    "Omission Detective": {
      kanji: "省",
      accent: "24 58% 56%",
      bg1: "22 48% 60%",
      bg2: "31 36% 74%",
      tilt: "-2deg",
    },
    "Register Radar": {
      kanji: "敬",
      accent: "137 34% 43%",
      bg1: "130 34% 50%",
      bg2: "154 38% 68%",
      tilt: "4deg",
    },
    "Transitivity Duel": {
      kanji: "他",
      accent: "205 100% 62%",
      bg1: "205 92% 58%",
      bg2: "250 72% 62%",
      tilt: "-3deg",
    },
    "Verb Conjugation": {
      kanji: "活",
      accent: "286 55% 70%",
      bg1: "285 42% 59%",
      bg2: "318 38% 68%",
      tilt: "5deg",
    },
  };
<article
  className="topic-card"
  style={
    {
      "--kanji": `"${cardStyle.kanji}"`,
      "--accent": cardStyle.accent,
      "--bg1": cardStyle.bg1,
      "--bg2": cardStyle.bg2,
      "--tilt": cardStyle.tilt,
    } as React.CSSProperties
  }
>
  <div className="topic-card-meta">
    <span>{topic.index}</span>
    <span>{topic.category}</span>
  </div>

  <h2 className="topic-card-title">{topic.title}</h2>

  <p className="topic-card-description">{topic.description}</p>

  <div className="topic-card-tags">
    {topic.tags.map((tag) => (
      <span key={tag}>{tag}</span>
    ))}
  </div>
</article>

type TopicCardStyle = {
    kanji: string;
    accent: string;
    bg1: string;
    bg2: string;
    tilt: string;
  };
  
  function getTopicCardStyle(topicName: string): TopicCardStyle {
    return topicStyleMap[topicName] ?? {
      kanji: "語",
      accent: "205 100% 62%",
      bg1: "205 92% 58%",
      bg2: "250 72% 62%",
      tilt: "-4deg",
    };
  }