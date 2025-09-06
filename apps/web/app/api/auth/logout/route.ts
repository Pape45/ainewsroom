import { NextResponse } from 'next/server';

const COOKIE_NAME = 'an_sess';

export async function POST() {
  const res = NextResponse.json({ ok: true });
  res.cookies.set({ name: COOKIE_NAME, value: '', path: '/', maxAge: 0 });
  return res;
}


