import 'dotenv/config';
import bcrypt from 'bcryptjs';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;
  if (!email || !password) {
    console.error('Missing ADMIN_EMAIL or ADMIN_PASSWORD in environment. Aborting seed.');
    process.exit(1);
  }
  const salt = bcrypt.genSaltSync(10);
  const hash = bcrypt.hashSync(password, salt);
  const user = await prisma.user.upsert({
    where: { email },
    update: { passwordHash: hash, role: 'ADMIN', status: 'active' },
    create: { email, passwordHash: hash, role: 'ADMIN' },
  });
  console.log('Seeded admin user:', user.email);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
}).finally(async () => {
  await prisma.$disconnect();
});

