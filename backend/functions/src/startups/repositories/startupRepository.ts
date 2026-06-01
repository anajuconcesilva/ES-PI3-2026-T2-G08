/**
 * Código feito por Lucas David de Sousa(disponibilizado pelo professor), RA: 25895152
 *
 */

import { FieldValue } from "firebase-admin/firestore";

import {
  QuestionStatus,
  QuestionVisibility,
  StartupDocument,
  StartupListItem,
  StartupQuestionDocument,
  StartupQuestionListItem,
} from "../types";

import { db } from "../shared/firebase";

const startupCollection = db.collection("startups");

const demoStartups: Array<StartupDocument & {id: string}> = [
  {
    id: "biochip-campus",
    name: "BioChip Campus",
    stage: "nova",
    shortDescription: "Sensores portáteis para análises laboratoriais " +
      "didáticas.",
    description: "A BioChip Campus simula kits de diagnóstico rápido para " +
      "laboratórios universitários, conectando sensores de baixo custo a um " +
      "aplicativo de acompanhamento.",
    executiveSummary: "Startup em fase de ideação com foco em prototipagem " +
      "de sensores educacionais e validação com cursos da área da saúde.",
    capitalRaisedCents: 1850000,
    totalTokensIssued: 100000,
    currentTokenPriceCents: 125,
    founders: [
      {
        name: "Ana Ribeiro",
        role: "CEO",
        equityPercent: 48,
        bio: "Responsável por estratégia e parceria acadêmicas.",
      },
      {
        name: "Lucas Moreira",
        role: "CTO",
        equityPercent: 37,
        bio: "Responsável por hardware e integração mobile.",
      },
      {name: "Mescla Labs", role: "Reserva estratégica", equityPercent: 15},
    ],
    externalMembers: [
      {
        name: "Dra. Helena Costa",
        role: "Mentora",
        organization: "PUC-Campinas",
      },
    ],
    demoVideos: ["https://example.com/videos/biochip-campus-demo"],
    pitchDeckUrl: "https://example.com/decks/biochip-campus.pdf",
    coverImageUrl: "https://images.unsplash.com/photo-" +
      "1581093458791-9d15482442f6",
    tags: ["healthtech", "iot", "educação"],
  },
  {
    id: "rota-verde",
    name: "Rota Verde",
    stage: "em_operacao",
    shortDescription: "Otimização de rotas sustentáveis para entregas urbanas.",
    description: "A Rota Verde usa dados de distância, emissão estimada e " +
      "ocupação de entregadores para sugerir rotas urbanas com menor impacto " +
      "ambiental.",
    executiveSummary: "Startup em operação piloto com pequenos comércios " +
      "locais e validação de indicadores de economia de comnustível.",
    capitalRaisedCents: 7400000,
    totalTokensIssued: 250000,
    currentTokenPriceCents: 310,
    founders: [
      {name: "Beatriz Santos", role: "CEO", equityPercent: 42},
      {name: "Rafael Almeida", role: "COO", equityPercent: 28},
      {name: "Carla Nogueira", role: "CTO", equityPercent: 20},
      {name: "Reserva de incentivos", role: "Pool", equityPercent: 10},
    ],
    externalMembers: [
      {name: "Marcos Lima", role: "Conselheiro", organization: "Mescla"},
      {
        name: "Patrícia Gomes",
        role: "Mentora",
        organization: "Rede de logística",
      },
    ],
    demoVideos: ["https://example.com/videos/rota-verde-demo"],
    pitchDeckUrl: "https://example.com/decks/rota-verde.pdf",
    coverImageUrl: "https://images.unsplash.com/photo-" +
      "1500530855697-b586d89ba3ee",
    tags: ["logtech", "sustentabilidade", "mobilidade"],
  },
  {
    id: "mentorai",
    name: "MentorAI",
    stage: "em_expansao",
    shortDescription: "Triagem inteligente para programas de mentoria " +
      "universitários.",
    description: "A MentorAI organiza perfis de estudantes e mentores para " +
      "recomendar encontros com base em objetivos, disponibilidade e " +
      "histórico de acompanhamento.",
    executiveSummary: "Startup em expansão com uso simulado em programas de " +
      "pré-aceleração e potencial de integração a plataformas educacionais.",
    capitalRaisedCents: 12350000,
    totalTokensIssued: 500000,
    currentTokenPriceCents: 525,
    founders: [
      {name: "Diego Martins", role: "CEO", equityPercent: 36},
      {name: "Juliana Vieira", role: "CPO", equityPercent: 25},
      {name: "Felipe Andrade", role: "CTO", equityPercent: 24},
      {
        name: "Investidores simulados",
        role: "Particpação externa",
        equityPercent: 15,
      },
    ],
    externalMembers: [
      {
        name: "Sofia Pereira",
        role: "Conselheira",
        organization: "Ecossistema Mescla",
      },
    ],
    demoVideos: ["https://example.com/videos/mentorai-demo"],
    pitchDeckUrl: "https://example.com/decks/mentorai.pdf",
    coverImageUrl: "https://images.unsplash.com/photo-" +
      "1552664730-d307ca884978",
    tags: ["edtech", "ia", "mentoria"],
  },
];

function toListItem(id: string, startup: StartupDocument): StartupListItem {
  return {
    id,
    name: startup.name,
    stage: startup.stage,
    shortDescription: startup.shortDescription,
    capitalRaisedCents: startup.capitalRaisedCents,
    totalTokensIssued: startup.totalTokensIssued,
    currentTokenPriceCents: startup.currentTokenPriceCents,
    coverImageUrl: startup.coverImageUrl,
    tags: startup.tags,
  };
}

export async function listStartupItems(): Promise<StartupListItem[]> {
  const snapshot = await startupCollection.limit(100).get();

  return snapshot.docs.map((doc) =>
    toListItem(doc.id, doc.data() as StartupDocument)
  );
}

export async function getStartupById(startupId: string): Promise<StartupDocument | undefined> {
  const startupSnapshot = await startupCollection.doc(startupId).get();

  if (!startupSnapshot.exists) {
    return undefined;
  }

  return startupSnapshot.data() as StartupDocument;
}

export async function userIsInvestor(startupId: string, uid: string): Promise<boolean> {
  const investorSnapshot = await startupCollection
    .doc(startupId)
    .collection("investors")
    .doc(uid)
    .get();

  return investorSnapshot.exists;
}

export async function userCanManageStartup(
  startupId: string,
  uid: string
): Promise<boolean> {
  const startupSnapshot = await startupCollection.doc(startupId).get();

  if (!startupSnapshot.exists) {
    return false;
  }

  const startup = startupSnapshot.data() as StartupDocument;

  if (startup.ownerUid === uid || startup.createdByUid === uid) {
    return true;
  }

  const managerSnapshot = await startupCollection
    .doc(startupId)
    .collection("managers")
    .doc(uid)
    .get();

  return managerSnapshot.exists;
}

function getTimestampAsIso(value: unknown): string | null {
  if (value && typeof value === "object" && "toDate" in value) {
    const date = (value as {toDate: () => Date}).toDate();
    return date.toISOString();
  }

  return null;
}

function getQuestionStatus(
  question: StartupQuestionDocument
): QuestionStatus {
  if (question.status) {
    return question.status;
  }

  return question.answer ? "respondida" : "pendente";
}

function toQuestionListItem(
  startupId: string,
  id: string,
  question: StartupQuestionDocument
): StartupQuestionListItem {
  return {
    id,
    startupId,
    authorUid: question.authorUid,
    text: question.text,
    visibility: question.visibility,
    status: getQuestionStatus(question),
    answer: question.answer ?? null,
    answeredAt: getTimestampAsIso(question.answeredAt),
    createdAt: getTimestampAsIso(question.createdAt),
    updatedAt: getTimestampAsIso(question.updatedAt),
  };
}

export async function listPublicQuestions(startupId: string) {
  const questionsSnapshot = await startupCollection
    .doc(startupId)
    .collection("questions")
    .where("visibility", "==", "publica")
    .limit(50)
    .get();

  return questionsSnapshot.docs
    .map((doc) => ({
      id: doc.id,
      text: doc.get("text"),
      answer: doc.get("answer") ?? null,
      answeredAt: doc.get("answeredAt")?.toDate?.()?.toISOString?.() ?? null,
      createdAt: doc.get("createdAt")?.toDate?.()?.toISOString?.() ?? null,
    }))
    .sort((left, right) => String(right.createdAt ?? "")
      .localeCompare(String(left.createdAt ?? "")));
}

export async function listQuestionsByStartup(
  startupId: string,
  options: {
    includePrivate: boolean;
    requesterUid: string;
    visibility?: QuestionVisibility;
    status?: QuestionStatus;
    limit?: number;
  }
): Promise<StartupQuestionListItem[]> {
  const questionsSnapshot = await startupCollection
    .doc(startupId)
    .collection("questions")
    .limit(options.limit ?? 100)
    .get();

  return questionsSnapshot.docs
    .map((doc) =>
      toQuestionListItem(
        startupId,
        doc.id,
        doc.data() as StartupQuestionDocument
      )
    )
    .filter((question) => {
      const canReadPrivate =
        options.includePrivate || question.authorUid === options.requesterUid;

      if (question.visibility === "privada" && !canReadPrivate) {
        return false;
      }

      if (options.visibility && question.visibility !== options.visibility) {
        return false;
      }

      if (options.status && question.status !== options.status) {
        return false;
      }

      return true;
    })
    .map((question) => ({
      ...question,
      askedByCurrentUser: question.authorUid === options.requesterUid,
    }))
    .sort((left, right) => String(right.createdAt ?? "")
      .localeCompare(String(left.createdAt ?? "")));
}

export async function getQuestionById(
  startupId: string,
  questionId: string
): Promise<StartupQuestionListItem | null> {
  const questionSnapshot = await startupCollection
    .doc(startupId)
    .collection("questions")
    .doc(questionId)
    .get();

  if (!questionSnapshot.exists) {
    return null;
  }

  return toQuestionListItem(
    startupId,
    questionSnapshot.id,
    questionSnapshot.data() as StartupQuestionDocument
  );
}

export async function answerQuestion(
  startupId: string,
  questionId: string,
  answer: string,
  answeredByUid: string
): Promise<void> {
  await startupCollection
    .doc(startupId)
    .collection("questions")
    .doc(questionId)
    .update({
      answer,
      answeredByUid,
      status: "respondida",
      answeredAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
}

export async function createQuestion(
  startupId: string,
  question: StartupQuestionDocument
): Promise<string> {
  const questionRef = await startupCollection
    .doc(startupId)
    .collection("questions")
    .add(question);

  return questionRef.id;
}

export async function seedDemoStartups(): Promise<string[]> {
  const batch = db.batch();

  for (const startup of demoStartups) {
    const {id, ...data} = startup;
    const startupRef = startupCollection.doc(id);
    batch.set(startupRef, {
      ...data,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
  }

  await batch.commit();

  return demoStartups.map((startup) => startup.id);
}