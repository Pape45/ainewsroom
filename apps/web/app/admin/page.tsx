import { redirect } from 'next/navigation';
import { requireAdminSession } from '@/lib/auth/server';

export default async function AdminDashboard() {
  const session = await requireAdminSession();
  if (!session) redirect('/admin/login');
  return (
    <main className="container mx-auto p-6">
      <h1 className="text-2xl font-semibold">Admin Dashboard</h1>
      <p className="text-gray-500 text-sm">Protected area. Moderation queue and draft details will appear here.</p>
      <div className="mt-4">
        <a href="/admin/queue" className="underline">Go to Moderation Queue →</a>
      </div>
      <form action="/api/auth/logout" method="post" className="mt-4">
        <button className="border rounded px-3 py-1">Logout</button>
      </form>
    </main>
  );
}


