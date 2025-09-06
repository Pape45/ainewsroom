import { redirect } from 'next/navigation';
import { requireAdminSession } from '@/lib/auth/server';
import { prisma } from '@/lib/db';

export default async function ModerationQueuePage() {
  const session = await requireAdminSession();
  if (!session) redirect('/admin/login');

  const drafts = await prisma.article.findMany({
    where: { status: { in: ['draft', 'pending_review'] } },
    orderBy: { updatedAt: 'desc' },
    select: { id: true, slug: true, seoTitle: true, status: true, updatedAt: true },
    take: 50,
  });

  return (
    <main className="container mx-auto p-6">
      <h1 className="text-2xl font-semibold mb-4">Moderation Queue</h1>
      {drafts.length === 0 ? (
        <p className="text-sm text-gray-500">No drafts or items pending review.</p>
      ) : (
        <ul className="divide-y">
          {drafts.map((d) => (
            <li key={d.id} className="py-3 flex items-center justify-between">
              <div>
                <div className="font-medium">{d.seoTitle || d.slug || d.id}</div>
                <div className="text-xs text-gray-500">{d.status} · {new Date(d.updatedAt).toLocaleString()}</div>
              </div>
              <a href={`/admin/draft/${d.id}`} className="text-sm underline">Open</a>
            </li>
          ))}
        </ul>
      )}
    </main>
  );
}


