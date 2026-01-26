/**
 * Automatische Insight-Generierung
 */

import * as admin from "firebase-admin";

const db = admin.firestore();

interface Insight {
  id: string;
  type: "trend" | "gap" | "achievement" | "recommendation";
  title: string;
  description: string;
  metric?: string;
  value?: number;
  createdAt: admin.firestore.FieldValue;
}

/**
 * Hauptfunktion: Generiert automatische Insights
 */
export async function generateInsights(): Promise<void> {
  console.log("Generating insights...");

  const insights: Insight[] = [];

  // Lade Overview-Daten
  const overviewDoc = await db
    .collection("analytics")
    .doc("region_overview")
    .get();
  const overview = overviewDoc.data();

  if (!overview) {
    console.warn("No overview data found");
    return;
  }

  const totalLocations = overview.totalLocations || 0;
  const categoryTotals = overview.categoryTotals || {};

  // Insight 1: Gesamtzahl
  insights.push({
    id: "total-locations",
    type: "achievement",
    title: `${totalLocations} Orte erfasst`,
    description:
      "Die MSH Map wächst weiter und bietet immer mehr Informationen für die Region.",
    metric: "locations",
    value: totalLocations,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Insight 2: Top-Kategorie
  const topCategory = Object.entries(categoryTotals).sort(
    (a, b) => (b[1] as number) - (a[1] as number)
  )[0];

  if (topCategory) {
    insights.push({
      id: "top-category",
      type: "trend",
      title: `${topCategory[0]} ist die stärkste Kategorie`,
      description: `Mit ${topCategory[1]} Einträgen ist "${topCategory[0]}" am besten abgedeckt.`,
      metric: topCategory[0],
      value: topCategory[1] as number,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // Insight 3: Spielplätze pro Einwohner
  const playgroundCount = categoryTotals["playground"] || 0;
  const totalPop = 120000; // Geschätzte Gesamtbevölkerung
  const playgroundPer10k = playgroundCount / (totalPop / 10000);

  if (playgroundPer10k < 2) {
    insights.push({
      id: "playground-shortage",
      type: "gap",
      title: "Spielplatz-Abdeckung verbesserungswürdig",
      description: `Nur ${playgroundPer10k.toFixed(
        1
      )} Spielplätze pro 10.000 Einwohner (Empfehlung: ≥3)`,
      metric: "playgrounds_per_10k",
      value: playgroundPer10k,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } else {
    insights.push({
      id: "playground-good",
      type: "achievement",
      title: "Gute Spielplatz-Versorgung",
      description: `${playgroundPer10k.toFixed(
        1
      )} Spielplätze pro 10.000 Einwohner`,
      metric: "playgrounds_per_10k",
      value: playgroundPer10k,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // Insight 4: Kategorien mit wenig Einträgen
  for (const [cat, count] of Object.entries(categoryTotals)) {
    if ((count as number) < 5 && cat !== "other") {
      insights.push({
        id: `low-${cat}`,
        type: "recommendation",
        title: `Mehr ${cat}-Daten sammeln`,
        description: `Die Kategorie "${cat}" hat nur ${count} Einträge. Hier fehlen noch Informationen.`,
        metric: cat,
        value: count as number,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }

  // Speichern
  const batch = db.batch();

  insights.forEach((insight) => {
    const docRef = db
      .collection("analytics")
      .doc("insights")
      .collection("items")
      .doc(insight.id);
    batch.set(docRef, insight);
  });

  await batch.commit();
  console.log(`Generated ${insights.length} insights`);
}
