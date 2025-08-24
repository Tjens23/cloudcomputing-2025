import type { MetaFunction } from "@remix-run/node";
import { json } from "@remix-run/node"; // or cloudflare/deno
import { Form, useActionData, useLoaderData, useNavigation } from "@remix-run/react";
import { useEffect, useRef } from "react";


export const meta: MetaFunction = () => {
  return [
    { title: "ThreeData" },
    { name: "description", content: "ThreeData" },
  ];
};

const API_ADDRESS = import.meta.env.VITE_API_ADDRESS;

type Question = {
  id: string | number;
  question: string;
  answer1: string;
  answer2: string;
  answer3: string;
  answer4: string;
  correct_answer: number | string;
};

export async function loader() {
  const res = await fetch(`${API_ADDRESS}/questions`);
  const data: Question[] = await res.json();
  return json<Question[]>(data);
}

export const action = async ({ request }: { request: Request }) => {
  const formData = await request.formData();
  const data = {
    question: formData.get('question'),
    answer1: formData.get('answer1'),
    answer2: formData.get('answer2'),
    answer3: formData.get('answer3'),
    answer4: formData.get('answer4'),
    // ensure numeric for backend
    correct_answer: Number(formData.get('correct_answer')),
  };

  try {
    const response = await fetch(`${API_ADDRESS}/questions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });

    console.log(response)

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const contentType = response.headers.get('content-type') || '';
    const result = contentType.includes('application/json')
      ? await response.json()
      : await response.text();
    console.log(result);
    const message = typeof result === 'string' ? result : undefined;
    return json<{ success: boolean; result?: unknown; message?: string; error?: string }>({ success: true, result, message });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Unknown error";
    console.log(message)
    return json<{ success: boolean; error?: string }>({ success: false, error: message });
  }
};

export default function Index() {
  const questions = useLoaderData<Question[]>();
  const actionData = useActionData<{ success: boolean; error?: string; message?: string }>();
  const navigation = useNavigation();
  const isSubmitting = navigation.state === "submitting";
  const formRef = useRef<HTMLFormElement>(null);

  useEffect(() => {
    if (actionData?.success) {
      formRef.current?.reset();
    }
  }, [actionData]);
  return (
    <div className="min-h-[100dvh] bg-gradient-to-b from-slate-50 to-white dark:from-slate-900 dark:to-slate-950">
      <div className="mx-auto max-w-5xl px-4 py-10 sm:py-14">
        <header className="mb-10">
          <div className="flex items-center gap-3">
            <img src="/logo-light.png" alt="ThreeData" className="h-8 w-8 dark:hidden" />
            <img src="/logo-dark.png" alt="ThreeData" className="h-8 w-8 hidden dark:block" />
            <h1 className="text-3xl font-semibold tracking-tight text-slate-900 dark:text-slate-100">ThreeData Questions</h1>
          </div>
          <p className="mt-2 text-slate-600 dark:text-slate-300">Browse existing questions and add new ones.</p>
        </header>

        {actionData?.success === true && (
          <div className="mb-6 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-emerald-800 dark:border-emerald-900/40 dark:bg-emerald-950/40 dark:text-emerald-200">
            {actionData.message || 'Question created successfully.'}
          </div>
        )}
        {actionData?.success === false && (
          <div className="mb-6 rounded-lg border border-rose-200 bg-rose-50 px-4 py-3 text-rose-800 dark:border-rose-900/40 dark:bg-rose-950/40 dark:text-rose-200">
            {actionData.error || 'Something went wrong creating the question.'}
          </div>
        )}

        <section>
          <h2 className="sr-only">Questions</h2>
          <ul className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {questions.map((q) => (
              <li key={q.id} className="group rounded-xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md dark:border-slate-800 dark:bg-slate-900">
                <div className="mb-3 flex items-start gap-2">
                  <span className="mt-1 inline-flex h-2 w-2 shrink-0 rounded-full bg-blue-500" aria-hidden />
                  <h3 className="text-base font-medium text-slate-900 dark:text-slate-100">{q.question}</h3>
                </div>
                <ol className="space-y-1.5 text-sm text-slate-700 dark:text-slate-300 list-decimal list-inside">
                  <li>{q.answer1}</li>
                  <li>{q.answer2}</li>
                  <li>{q.answer3}</li>
                  <li>{q.answer4}</li>
                </ol>
                <details className="mt-4">
                  <summary className="cursor-pointer select-none text-sm font-semibold text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300">Show answer</summary>
                  <div className="mt-2 rounded-md bg-slate-50 p-3 text-sm text-slate-800 dark:bg-slate-800 dark:text-slate-200">
                    Correct option: <span className="font-semibold">{q.correct_answer}</span>
                  </div>
                </details>
              </li>
            ))}
          </ul>
        </section>

        <section className="mt-12">
          <h2 className="mb-4 text-xl font-semibold text-slate-900 dark:text-slate-100">Add new question</h2>
          <Form ref={formRef} method="post" action="/?index" className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="sm:col-span-2">
                <label htmlFor="question" className="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">Question</label>
                <input id="question" name="question" type="text" required placeholder="Enter the question text" className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100" />
              </div>
              <div>
                <label htmlFor="answer1" className="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">Answer 1</label>
                <input id="answer1" name="answer1" type="text" required placeholder="Option 1" className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100" />
              </div>
              <div>
                <label htmlFor="answer2" className="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">Answer 2</label>
                <input id="answer2" name="answer2" type="text" required placeholder="Option 2" className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100" />
              </div>
              <div>
                <label htmlFor="answer3" className="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">Answer 3</label>
                <input id="answer3" name="answer3" type="text" required placeholder="Option 3" className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100" />
              </div>
              <div>
                <label htmlFor="answer4" className="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">Answer 4</label>
                <input id="answer4" name="answer4" type="text" required placeholder="Option 4" className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100" />
              </div>
              <div>
                <label htmlFor="correct_answer" className="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">Correct Answer (1-4)</label>
                <input id="correct_answer" name="correct_answer" type="number" inputMode="numeric" min={1} max={4} step={1} required placeholder="e.g. 2" className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100" />
              </div>
            </div>
            <div className="mt-6 flex items-center gap-3">
              <button
                className="inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500/40 disabled:cursor-not-allowed disabled:opacity-60"
                type="submit"
                disabled={isSubmitting}
              >
                {isSubmitting ? 'Creating…' : 'Create question'}
              </button>
              <p className="text-xs text-slate-500 dark:text-slate-400">Your submission will refresh the list automatically.</p>
            </div>
          </Form>
        </section>
      </div>
    </div>
  );
}
