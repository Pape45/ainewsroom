import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Article | AI Newsroom",
};

export default function ArticlePage({ params }: { params: { slug: string } }) {
  return (
    <main className="container mx-auto p-6 prose dark:prose-invert">
      <h1 className="mb-2">Article: {params.slug}</h1>
      <p className="text-sm text-gray-500">Detail placeholder. JSON-LD and citations will be added in V1 publish pipeline.</p>
    </main>
  );
}

