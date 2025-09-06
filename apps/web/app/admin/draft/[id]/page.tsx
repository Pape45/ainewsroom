import { redirect } from 'next/navigation';
import { prisma } from '@/lib/db';
import { requireAdminSession } from '@/lib/auth/server';

type Props = { params: { id: string } };

export default async function DraftDetailPage({ params }: Props) {
  const session = await requireAdminSession();
  if (!session) redirect('/admin/login');

  const draft = await prisma.article.findUnique({ where: { id: params.id }, include: { sections: true, citations: true, item: true } });
  if (!draft) {
    return (
      <main className="container mx-auto p-6">
        <p>Draft not found.</p>
      </main>
    );
  }
  return (
    <main className="container mx-auto p-6 space-y-2">
      <h1 className="text-2xl font-semibold">{draft.seoTitle || draft.slug || 'Untitled draft'}</h1>
      <div className="text-sm text-gray-500">Status: {draft.status}</div>
      <pre className="bg-gray-50 dark:bg-gray-900 p-4 rounded overflow-auto text-xs">
        {JSON.stringify(draft, null, 2)}
      </pre>
      <div className="flex gap-2">
        <form action="#" method="post"><button disabled className="border rounded px-3 py-1 opacity-60">Publish (stub)</button></form>
        <form action="#" method="post"><button disabled className="border rounded px-3 py-1 opacity-60">Reject (stub)</button></form>
      </div>
    </main>
  );
}


