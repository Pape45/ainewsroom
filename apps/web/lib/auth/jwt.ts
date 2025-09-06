import crypto from 'crypto';

function base64url(input: Buffer | string) {
  return (typeof input === 'string' ? Buffer.from(input) : input)
    .toString('base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
}

export function signJWT(payload: Record<string, unknown>, secret: string, expiresInSec = 60 * 60 * 24 * 7) {
  const header = { alg: 'HS256', typ: 'JWT' };
  const now = Math.floor(Date.now() / 1000);
  const body = { iat: now, exp: now + expiresInSec, ...payload };
  const headerB64 = base64url(JSON.stringify(header));
  const payloadB64 = base64url(JSON.stringify(body));
  const data = `${headerB64}.${payloadB64}`;
  const sig = crypto.createHmac('sha256', secret).update(data).digest();
  return `${data}.${base64url(sig)}`;
}

type JWTPayload = { exp?: number; iat?: number; [k: string]: unknown };

export function verifyJWT(token: string, secret: string): { valid: boolean; payload?: JWTPayload } {
  try {
    const [h, p, s] = token.split('.');
    if (!h || !p || !s) return { valid: false };
    const data = `${h}.${p}`;
    const expected = base64url(crypto.createHmac('sha256', secret).update(data).digest());
    if (expected !== s) return { valid: false };
    const payload = JSON.parse(Buffer.from(p, 'base64').toString('utf8')) as JWTPayload;
    const now = Math.floor(Date.now() / 1000);
    if (payload.exp && now > payload.exp) return { valid: false };
    return { valid: true, payload };
  } catch {
    return { valid: false };
  }
}


