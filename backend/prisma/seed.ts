/// <reference types="node" />
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting Clean Database Setup (Zero Dummy Creators)...');

  // 1. Create Default Admin Settings (Essential for payment and live call engine)
  await prisma.adminSetting.upsert({
    where: { id: 1 },
    update: {},
    create: {
      id: 1,
      isFreezeBalance: false,
      isVideoConnectionEnabled: true,
      paymentUpiId: 'linkup@ybl',
    },
  });

  console.log('✅ Admin settings initialized.');

  // 2. Remove any previous dummy/sample creator data so ONLY real users appear
  const dummyPhones = [
    '+919876543210',
    '+919876543211',
    '+919876543212',
    '+919876543213',
    '+919876543214',
    '+919876543215',
    '+919876543216',
  ];

  await prisma.creator.deleteMany({
    where: {
      user: {
        phone: { in: dummyPhones },
      },
    },
  });

  await prisma.user.deleteMany({
    where: {
      phone: { in: dummyPhones },
    },
  });

  console.log('✨ Clean slate ready: Zero dummy creators.');
  console.log('🎉 From now on, ONLY real users who click "Become a Creator" will appear on the Home Screen!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
