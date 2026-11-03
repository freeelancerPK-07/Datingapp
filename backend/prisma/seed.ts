/// <reference types="node" />
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting Clean Database Setup (Purging All Dummy Creators)...');

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

  const dummyEmails = [
    'sneha@linkup.app',
    'kavya@linkup.app',
    'rohan@linkup.app',
    'aanya@linkup.app',
  ];

  const dummyNames = [
    'Sneha Roy',
    'Kavya Nair',
    'Rohan Mehra',
    'Aanya Sharma',
  ];

  // Find dummy user IDs
  const dummyUsers = await prisma.user.findMany({
    where: {
      OR: [
        { phone: { in: dummyPhones } },
        { email: { in: dummyEmails } },
        { profile: { name: { in: dummyNames } } },
      ],
    },
    select: { id: true },
  });

  const dummyIds = dummyUsers.map((u) => u.id);

  if (dummyIds.length > 0) {
    console.log(`Found ${dummyIds.length} dummy users to purge:`, dummyIds);

    await prisma.creatorApplication.deleteMany({
      where: { userId: { in: dummyIds } },
    });

    await prisma.creator.deleteMany({
      where: { userId: { in: dummyIds } },
    });

    await prisma.walletTransaction.deleteMany({
      where: { wallet: { userId: { in: dummyIds } } },
    });

    await prisma.wallet.deleteMany({
      where: { userId: { in: dummyIds } },
    });

    await prisma.userProfile.deleteMany({
      where: { userId: { in: dummyIds } },
    });

    await prisma.user.deleteMany({
      where: { id: { in: dummyIds } },
    });

    console.log(`🗑️ Successfully deleted all ${dummyIds.length} dummy creators & users from PostgreSQL!`);
  } else {
    console.log('✨ Clean slate: No dummy creators found in database.');
  }

  console.log('🎉 From now on, ONLY real users who register and click "Become a Creator" will appear on Home Screen!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
