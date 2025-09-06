import { cookies } from 'next/headers';
import { verifyJWT } from '@/lib/auth/jwt';

const COOKIE_NAME = 'an_sess';

export async function requireAdminSession() {
  const cookieStore = await cookies();
  const token = cookieStore.get(COOKIE_NAME)?.value;
  const secret = process.env.APP_AUTH_SECRET || '';
  if (!token || !secret) return null;
  const { valid, payload } = verifyJWT(token, secret);
  if (!valid) return null;
  return payload;
}


