export default function AuthorPage({ params }: { params: { slug: string } }) {
  return (
    <main className="container mx-auto p-6">
      <h1 className="text-2xl font-semibold">Author: {params.slug}</h1>
      <p className="text-sm text-gray-500">Author profile placeholder.</p>
    </main>
  );
}

